ENV['RACK_ENV'] = 'test'

require File.join(File.dirname(__FILE__), %w{ .. examples application })

require 'spec'
require 'spec/expectations'
require 'rack/test'
require 'webrat'
require 'pony-test'

DataMapper.setup(:default, "sqlite3::memory:")

Webrat.configure do |config|
  config.mode = :rack
end

Spec::Runner.configure do |config|
  config.before(:each) { DataMapper.auto_migrate! }
end
