require 'rubygems'
require 'bundler/setup'

require 'simplecov'
require 'simplecov-gem-adapter'

require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]

SimpleCov.start 'gem'

require 'i18n'
I18n.enforce_available_locales = false

require 'mongoid'
require 'active_record'
require 'active_mongoid'
require 'database_cleaner'

require 'pry'

require 'rspec'

Mongoid.configure do |config|
    config.sessions = {
        default: {
          database: 'active_mongoid_test',
          hosts: [ (ENV['MONGO_HOST'] || 'localhost')+':27017' ],
          options: { read: :primary }
        }
      }
end

RSpec.configure do |config|
  config.mock_with :rspec

  config.before :suite do
    DatabaseCleaner[:active_record].strategy = :transaction
    DatabaseCleaner[:active_record].clean_with :truncation
    DatabaseCleaner[:mongoid].clean_with :truncation
  end

  config.before :each do
    DatabaseCleaner[:active_record].start
    DatabaseCleaner[:mongoid].start
  end

  config.after :each do
    DatabaseCleaner[:active_record].clean
    DatabaseCleaner[:mongoid].clean
  end
end


ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => ':memory:'
ActiveRecord::Schema.define do
  create_table :players, :force => true do |t|
    t.string :_id
    t.string :name
    t.string :title
    t.string :team_id
  end

  create_table :divisions, :force => true do |t|
    t.string :_id
    t.string :name
    t.string :league_id
    t.string :pid
    t.string :sport_id
  end

  create_table :division_settings, :force => true do |t|
    t.string :_id
    t.string :name
    t.string :league_id
  end

  create_table :addresses, :force => true do |t|
    t.string :_id
    t.string :target_id
    t.string :target_type
  end
end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
