Rails.application.config.schemas_directory = File.join(Rails.root, 'schemas')

schemas = Dir.glob("#{Rails.application.config.schemas_directory}/*/**")
schemas.each do |schema_file|
  schema = JSON.parse(File.read(schema_file))
  jschema = JSON::Schema.new(schema, Addressable::URI.parse(schema['_name']))
  JSON::Validator.add_schema(jschema)
end
