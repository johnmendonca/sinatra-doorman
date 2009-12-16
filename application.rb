require 'rubygems'
require 'sinatra'
require 'haml'
require 'warden'

require 'lib/bouncer'

use Rack::Session::Cookie

use Warden::Manager do |manager|
  manager.default_strategies :password
  manager.failure_app = Sinatra::Application
end

use Rack::Flash

configure :development do
  DataMapper.setup(:default, "sqlite3:///#{File.expand_path(File.dirname(__FILE__))}/development.db")
end

configure :test do
  #explicitly declare view folder for testing with webrat
  set :views, "#{File.dirname(__FILE__)}/views"
end

helpers do
  # add your helpers here
end

get '/' do
  haml :root
end
