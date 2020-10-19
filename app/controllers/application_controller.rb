class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :resource_not_found

  private

  def resource_not_found
    render json: { message: 'Resource not found' }, status: :not_found
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
      {}
    end
  end
end
