ENV['RACK_ENV'] = 'test'

require File.join(File.dirname(__FILE__), %w{ .. application })

require 'spec'
require 'spec/expectations'
require 'rack/test'
require 'webrat'

DataMapper.setup(:default, "sqlite3::memory:")

Webrat.configure do |config|
  config.mode = :rack
end

Spec::Runner.configure do |config|
  config.before(:each) { DataMapper.auto_migrate! }
end
