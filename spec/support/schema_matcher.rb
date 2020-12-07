RSpec::Matchers.define :match_schema do |schema|
  match do |metadata|
    MetadataPresenter::ValidateSchema.validate(metadata, schema)
  end
end
