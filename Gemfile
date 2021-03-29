source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.2'
# Metadata presenter - if you need to be on development you can uncomment
# one of these lines:
gem 'metadata_presenter',
     git: 'git@github.com:ministryofjustice/fb-metadata-presenter.git',
     branch: 'page-types-in-base-schema'
#gem 'metadata_presenter', path: '../fb-metadata-presenter'
# gem 'metadata_presenter', '~> 0.21.1'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'fb-jwt-auth', '~> 0.6.0'
gem 'pg', '>= 0.18', '< 2.0'
gem 'prometheus-client', '~> 2.1.0'
gem 'puma', '~> 5.2'
gem 'rails', '~> 6.1.3'
gem 'sentry-ruby', '~> 4.3.1'
gem 'sentry-rails', '~> 4.3.2'
gem 'tzinfo-data'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'httparty'
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'database_cleaner-active_record'
end

group :development do
  gem 'brakeman'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
