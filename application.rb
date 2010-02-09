require 'rubygems'
require 'sinatra'
require 'haml'
require 'warden'

require 'lib/doorman'

configure :development do
  DataMapper.setup(:default, "sqlite3:///#{File.expand_path(File.dirname(__FILE__))}/development.db")
end

configure :test do
  #explicitly declare view folder for testing with webrat
  set :views, "#{File.dirname(__FILE__)}/views"
end

not_found do
  flash[:error] = "The page you are looking for cannot be found"
  redirect '/'
end

use Rack::Session::Cookie
use Rack::Flash

Sinatra.register Sinatra::Doorman::Base
Sinatra.register Sinatra::Doorman::RememberMe
Sinatra.register Sinatra::Doorman::ForgotPassword

get '/' do
  haml :root
end

get '/home/?' do
  env['warden'].authenticate!
  haml :home
end
