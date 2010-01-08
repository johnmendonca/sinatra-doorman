require 'rubygems'
require 'sinatra'
require 'haml'
require 'warden'

require 'lib/bouncer'

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

get '/' do
  haml :root
end
