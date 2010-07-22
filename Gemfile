source 'http://rubygems.org'

RSPEC_VERSION = '~> 2.0.0.beta.18'
MONGOID_VERSION = '~> 2.0.0.beta9'

gem 'bson_ext', '1.0.4'
gem 'mongoid', MONGOID_VERSION

group(:test) do
  gem 'rspec',              RSPEC_VERSION
  gem 'rspec-core',         RSPEC_VERSION, :require => 'rspec/core'
  gem 'rspec-expectations', RSPEC_VERSION, :require => 'rspec/expectations'
  gem 'rspec-mocks',        RSPEC_VERSION, :require => 'rspec/mocks'
  
  gem 'database_cleaner'
end

