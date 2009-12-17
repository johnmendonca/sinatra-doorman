#load email_spec submodule for time being
$: << File.join(File.expand_path(File.dirname(__FILE__)), %w{ .. email_spec lib })

ENV['RACK_ENV'] = 'test'

require File.join(File.dirname(__FILE__), %w{ .. application })

require 'spec'
require 'spec/expectations'
require 'rack/test'
require 'webrat'
require 'email_spec'

DataMapper.setup(:default, "sqlite3::memory:")

Webrat.configure do |config|
  config.mode = :rack
end

Spec::Runner.configure do |config|
  config.before(:each) { DataMapper.auto_migrate! }
end
