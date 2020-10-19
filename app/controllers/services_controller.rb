class ServicesController < ApplicationController
  def create
    service = Service.new(service_params)

    if service.save
      metadata = service.latest_metadata

      render(
        json: MetadataSerialiser.new(service, metadata).attributes,
        status: :created
      )
    else
      render json: { message: service.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
