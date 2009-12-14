require File.join(File.dirname(__FILE__), %w{ .. application })

require 'spec'
require 'spec/expectations'
require 'rack/test'
require 'webrat'
require 'factory_girl'

DataMapper.setup(:default, "sqlite3::memory:")

Webrat.configure do |config|
  config.mode = :rack
end

Factory.sequence :email do |n|
  "user#{n}@example.com"
end

Factory.define :user do |user|
  user.email                 { Factory.next :email }
  user.password              { "password" }
  user.password_confirmation { "password" }
end

Factory.define :email_confirmed_user, :parent => :user do |user|
  user.email_confirmed { true }
end

Spec::Runner.configure do |config|
  config.before(:each) { DataMapper.auto_migrate! }
end
