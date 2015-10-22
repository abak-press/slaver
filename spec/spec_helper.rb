$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'bundler/setup'
require 'simplecov'
SimpleCov.start do
  minimum_coverage 90
end

require 'slaver'

require 'combustion'
Combustion.initialize! :all
require 'rspec/rails'

require 'shoulda-matchers'
require 'database_cleaner'

abcs = YAML.load(ERB.new(File.read("#{Rails.root}/config/database.yml")).result)
Combustion::Database.drop_database(abcs['test_other'])
Combustion::Database.create_database(abcs['test_other'])
Combustion::Database.load_schema

ActiveRecord::Base.clear_active_connections!
ActiveRecord::Base.establish_connection(abcs['test'])

RSpec.configure do |config|
  config.use_transactional_fixtures = false

  DatabaseCleaner.strategy = :truncation

  config.after(:each) do
    ActiveRecord::Base.establish_connection :test_other
    DatabaseCleaner.clean

    ActiveRecord::Base.establish_connection :test
    DatabaseCleaner.clean
  end
end
