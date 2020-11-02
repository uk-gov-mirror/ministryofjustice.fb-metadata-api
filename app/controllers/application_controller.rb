class ApplicationController < ActionController::API
  RECORD_NOT_FOUND_EXCEPTIONS = [
    ActiveRecord::RecordNotFound,
    MetadataVersionNotFound
  ]
  rescue_from(*RECORD_NOT_FOUND_EXCEPTIONS) do |exception|
    render json: ErrorsSerializer.new(
      exception, message: exception.message
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
      exception, message: exception.message
    ).attributes, status: :unauthorized
  end

  before_action AuthenticateApplication

  private

  def resource_not_found(exception)
    render json: ErrorsSerializer.new(exception).attributes, status: :not_found
  end

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
end
