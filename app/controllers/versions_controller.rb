class VersionsController < ApplicationController
  def create
    service = Service.find(params[:service_id])

    if service.update(service_params)
      metadata = service.last_metadata

      render(
        json: MetadataSerialiser.new(service, metadata).attributes,
        status: :created
      )
    else
      render json: { message: service.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
