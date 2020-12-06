module Helpers
  def fixtures_directory
    MetadataPresenter::Engine.root.join('spec', 'fixtures')
  end
end
