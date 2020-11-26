class SchemaNotFoundError < StandardError
end

class ValidateSchema
  class << self
    def before(controller)
      schema = "request.#{controller.request.params['controller']}"
      validate(controller.request.params, schema)
    end

    def validate(metadata, schema)
      service_schema = find(schema)
      JSON::Validator.validate!(service_schema, metadata)
    end

    def find(schema)
      schema_file = schema.gsub('.', '/')
      schema = File.read(File.join(
        Rails.application.config.schemas_directory, "#{schema_file}.json")
      )
      JSON.parse(schema)
    rescue Errno::ENOENT
      raise SchemaNotFoundError.new("Schema not found => #{schema}")
    end
  end
end
