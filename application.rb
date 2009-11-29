require 'rubygems'
require 'sinatra'
require 'haml'

require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'

require 'lib/models/profile'

configure do
  DataMapper.setup(:default, "sqlite3:///#{File.expand_path(File.dirname(__FILE__))}/#{Sinatra::Base.environment}.db")
end

helpers do
  # add your helpers here
end

get '/' do
  haml :root
end
