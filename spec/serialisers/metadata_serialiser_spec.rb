RSpec.describe MetadataSerialiser do
  let(:service_metadata) do
    JSON.parse(File.read(fixtures_directory.join('service.json')))
  end
  let(:service_params) do
    {
      name: service_metadata['service_name'],
      created_by: service_metadata['created_by'],
      metadata_attributes: [{
        data: service_metadata,
        created_by: service_metadata['created_by'],
        locale: service_metadata['locale'] || 'en'
      }]
    }
  end

  context '#latest_metadata' do
    it 'metadata should be valid against the base schema' do
      service = Service.create(service_params)
      serialiser = MetadataSerialiser.new(service, service.latest_metadata)
      expect(serialiser.attributes).to match_schema('service.base')
    end
  end
end
