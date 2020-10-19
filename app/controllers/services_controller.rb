class ServicesController < ApplicationController
  def show
    service = Service.find(params[:id])
    metadata = service.last_metadata

    render json: MetadataSerialiser.new(service, metadata).attributes, status: :ok
  end

  def create
    service = Service.new(service_params)

    if service.save
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
