class MetadataSerialiser
  include ActiveModel::Serializers::JSON

  attr_accessor :service, :metadata

  def initialize(service, metadata)
    @service = service
    @metadata = metadata
  end

  def attributes
    {
      service_id: service.id,
      service_name: service.name,
      created_by: service.created_by,
      version_id: metadata.id,
      locale: metadata.locale
    }.merge(metadata.data)
  end
end
