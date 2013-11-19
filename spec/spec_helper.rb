require 'rspec'
require 'rails'
require 'active_record'
require 'active_record/errors'
require 'syrup'
require 'nulldb_rspec'

include NullDB::RSpec::NullifiedDatabase

NullDB.configure do |config|
  config.project_root = File.expand_path("..", __FILE__)
end


RSpec.configure do |config|
end
