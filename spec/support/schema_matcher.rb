RSpec::Matchers.define :match_schema do |schema|
  match do |metadata|
    ValidateSchema.validate(metadata, schema)
  end
end
