class VersionsController < ApplicationController
  def create
    service = Service.find(params[:service_id])

    if service.update(service_params)
      metadata = service.latest_metadata

      render(
        json: MetadataSerialiser.new(service, metadata).attributes,
        status: :created
      )
    else
      render json: { message: service.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def latest
    service = Service.find(params[:service_id])
    locale = params[:locale] || 'en'
    metadata = service.metadata.by_locale(locale).latest_version

    render json: MetadataSerialiser.new(service, metadata).attributes, status: :ok
  end
end
