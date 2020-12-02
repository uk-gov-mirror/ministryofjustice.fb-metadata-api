class SchemaNotFoundError < StandardError
end

class ValidateSchema
  class << self
    def before(controller)
      return unless controller.request.post?

      schema_name = "request.#{controller.request.params['controller']}"
      validate(controller.request.params, schema_name)
    rescue JSON::Schema::ValidationError, JSON::Schema::SchemaError, SchemaNotFoundError => e
      controller.render(
        json: ErrorsSerializer.new(message: e.message).attributes,
        status: :unprocessable_entity
      )
    end

    def validate(metadata, schema_name)
      schema = Rails.application.config.schemas[schema_name] ||= find(schema_name)
      JSON::Validator.validate!(schema, metadata)
    end

    def find(schema_name)
      schema_file = schema_name.gsub('.', '/')
      schema = File.read(File.join(
        Rails.application.config.schemas_directory, "#{schema_file}.json")
      )
      JSON.parse(schema)
    rescue Errno::ENOENT
      raise SchemaNotFoundError.new("Schema not found => #{schema_name}")
    end
  end
end
