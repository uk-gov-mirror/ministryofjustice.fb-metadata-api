class ApplicationController < ActionController::API
  NOT_FOUND_EXCEPTIONS = [
    ActiveRecord::RecordNotFound,
    MetadataVersionNotFound
  ]
  rescue_from(*NOT_FOUND_EXCEPTIONS) do |exception|
    render json: ErrorsSerializer.new(
      message: exception.message
    ).attributes, status: :not_found
  end

  FB_JWT_EXCEPTIONS = [
    Fb::Jwt::Auth::TokenNotPresentError,
    Fb::Jwt::Auth::TokenNotValidError,
    Fb::Jwt::Auth::IssuerNotPresentError,
    Fb::Jwt::Auth::NamespaceNotPresentError,
    Fb::Jwt::Auth::TokenExpiredError
  ]
  rescue_from(*FB_JWT_EXCEPTIONS) do |exception|
    render json: ErrorsSerializer.new(
      message: exception.message
    ).attributes, status: :unauthorized
  end

  before_action AuthenticateApplication
  before_action :validate_schema

  def not_found
    render json: ErrorsSerializer.new(
      message: "No route matches #{request.method} '#{request.path}'"
    ).attributes, status: :not_found
  end

  private

  def service_params
    params.permit(:metadata)
    attributes = params[:metadata]

    if attributes
      {
        name: attributes[:service_name],
        created_by: attributes[:created_by],
        metadata_attributes: [{
          data: attributes,
          created_by: attributes[:created_by],
          locale: attributes[:locale] || 'en'
        }]
      }
    else
      {
        name: nil,
        created_by: nil,
        metadata_attributes: [{}]
      }
    end
  end

  def validate_schema
    ValidateSchema.before(self) if request.post?
  rescue JSON::Schema::ValidationError, JSON::Schema::SchemaError, SchemaNotFoundError => e
    render json:
      ErrorsSerializer.new(
        message: e.message
      ).attributes, status: :unprocessable_entity
  end
end
