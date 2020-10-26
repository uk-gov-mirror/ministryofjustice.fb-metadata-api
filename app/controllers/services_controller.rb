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
      render json:
        ErrorsSerializer.new(
          service,
          message: service.errors.full_messages
      ).attributes, status: :unprocessable_entity
    end
  end

  def services_for_user
    services = Service.joins(:metadata).where("metadata.created_by" => params[:user_id])

    render json: ServicesSerializer.new(services).attributes, status: :ok
  end
end
