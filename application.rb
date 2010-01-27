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
use Warden::Manager do |manager|
  manager.failure_app = lambda { |env|
    env['x-rack.flash'][:error] = :authentication_required
    [302, { 'Location' => '/login' }, ['']] 
  }
  manager.strategies.add(:password, Sinatra::Doorman::PasswordStrategy) 
  manager.strategies.add(:remember_me, Sinatra::Doorman::RememberMeStrategy)
  manager.default_strategies :remember_me
end

get '/' do
  haml :root
end
