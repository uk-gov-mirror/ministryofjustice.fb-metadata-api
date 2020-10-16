class ServicesController < ApplicationController
  def create
    service = Service.new(service_params)

    if service.save
      metadata = service.metadata.last

      render json: {
        service_id: service.id,
        service_name: service.name,
        created_by: service.created_by,
        version_id: metadata.id,
        locale: metadata.locale
      }.merge(metadata.data), status: :created
    else
      render json: { message: service.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
