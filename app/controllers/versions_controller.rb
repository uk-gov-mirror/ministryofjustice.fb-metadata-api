class VersionsController < ApplicationController
  def create
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
    metadata = service.metadata.by_locale(locale).latest_version

    render json: MetadataSerialiser.new(service, metadata).attributes, status: :ok
  end

  def index
    versions = service.metadata.by_locale(locale).all_versions.ordered

    render json: VersionsSerialiser.new(service, versions).attributes, status: :ok
  end

  def service
    @_service ||= Service.find(params[:service_id])
  end

  def locale
    @_locale ||= params[:locale] || 'en'
  end
end
