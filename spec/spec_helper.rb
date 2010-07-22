begin
  require 'bundler'
  Bundler.setup
  Bundler.require(:default, :test)
rescue LoadError
  puts 'Bundler is not installed, you need to gem install it in order to run the specs.'
  exit 1
end

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir[File.expand_path('support/**/*.rb', File.dirname(__FILE__))].each { |f| require f }

# Requires lib.
Dir[File.expand_path('../lib/**/*.rb', File.dirname(__FILE__))].each { |f| require f }

# Setup Mongoid.
Mongoid.configure do |config|
  name = "query_string_interface_test"
  config.master = Mongo::Connection.new.db(name)
  config.allow_dynamic_fields = true
  config.use_object_ids = true
end

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end
  
  config.before(:each) do
    DatabaseCleaner.clean
  end
end
