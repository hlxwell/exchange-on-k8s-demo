require "rubygems"
require "active_record"

include ActiveRecord::Tasks

def init_database_tasks
  DatabaseTasks.env = ENV["ENV"] || "development"
  DatabaseTasks.root = File.dirname(__FILE__)
  DatabaseTasks.database_configuration = YAML.load(ERB.new(File.read("database.yml")).result)
end

def init_activerecord
  ActiveRecord::Base.configurations = DatabaseTasks.database_configuration
  ActiveRecord::Base.establish_connection DatabaseTasks.env.to_sym
end

def load_models
  Dir["app/models/*.rb"].each do |file|
    require_relative File.join(File.dirname(__FILE__), "..", file)
  end
end

init_database_tasks
init_activerecord
load_models

RSpec.configure do |config|
  config.expect_with(:rspec) { |c|
    c.syntax = :should
  }
  config.raise_errors_for_deprecations!
end
