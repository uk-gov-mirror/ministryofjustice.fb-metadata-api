class MetadataSerialiser
  attr_accessor :service, :metadata

  def initialize(service, metadata)
    @service = service
    @metadata = metadata
  end

  def attributes
    metadata.data.merge(
      service_id: service.id,
      service_name: service.name,
      created_by: service.created_by,
      locale: metadata.locale,
      created_at: metadata.created_at.iso8601,
      version_id: metadata.id
    )
  end
end
