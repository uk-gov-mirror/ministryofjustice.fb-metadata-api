class VersionsSerialiser
  attr_accessor :service, :versions

  def initialize(service, versions)
    @service = service
    @versions = versions
  end

  def attributes
    {
      service_id: service.id,
      service_name: service.name,
      versions: all_versions
    }
  end

  private

  def all_versions
    versions.map do |version|
      {
        version_id: version.id,
        created_at: version.created_at.iso8601
      }
    end
  end
end
