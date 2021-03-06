# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Lazy loading associations for the ActiveRecord models
# https://github.com/DmitryTsepelev/ar_lazy_preload
gem 'ar_lazy_preload'

# Flexible authentication solution for Rails with Warden.
# https://github.com/plataformatec/devise
gem 'devise'

# OAuth 2 provider for Ruby on Rails / Grape.
# https://github.com/doorkeeper-gem/doorkeeper
gem 'doorkeeper', '~> 5.3.2'

# A Ruby implementation of GraphQL.
# https://github.com/rmosolgo/graphql-ruby
gem 'graphql', '>= 1.10.4'

# https://github.com/ohler55/oj
# A fast JSON parser and Object marshaller as a Ruby gem.
gem 'oj'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.3'

# Settingslogic is a simple configuration / settings solution that uses an ERB enabled YAML file.
# https://github.com/binarylogic/settingslogic
gem 'settingslogic'

# A Ruby/Rack web server built for concurrency
# https://github.com/puma/puma
gem 'puma', '>= 4.3.5'

# A Ruby interface to the PostgreSQL RDBMS.
# https://github.com/ged/ruby-pg
gem 'pg'

# Rack middleware for blocking & throttling
# https://github.com/kickstarter/rack-attack
gem 'rack-attack'

# Rack Middleware for handling Cross-Origin Resource Sharing (CORS), which makes cross-origin AJAX possible.
# https://github.com/cyu/rack-cors
gem 'rack-cors', '>= 1.0.6', require: 'rack/cors'

# Cache
gem 'connection_pool'
gem 'redis'
gem 'redis-namespace'
gem 'redis-rails'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'rspec-parameterized', require: false
  gem 'rspec-rails'
end

group :development do
  # Help to kill N+1 queries and unused eager loading
  # https://github.com/flyerhzm/bullet
  gem 'bullet'
  gem 'graphiql-rails'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'pry-rails'
end

group :test do
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-sqlimit'
  gem 'rspec_junit_formatter'
  gem 'shoulda-matchers', '>= 4.0.0'
  gem 'simplecov'

  # Ruby Tests Profiling Toolbox
  # https://github.com/palkan/test-prof
  gem 'test-prof'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
