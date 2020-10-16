class VersionsController < ApplicationController
  def create
    service = Service.find(params[:service_id])

    if service.update(service_params)
      metadata = service.metadata.order(created_at: :desc).first

      render json: {
        service_id: service.id,
        service_name: service.name,
        created_by: service.created_by,
        version_id: metadata.id,
        locale: metadata.locale
      }.merge(metadata.data), status: :ok
    else
      render json: { message: service.errors.full_messages }, status: :unprocessable_entity
    end
  end

end
