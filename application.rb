require 'rubygems'
require 'sinatra'
require 'haml'

require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'

require 'lib/models/user'

configure :development do
  DataMapper.setup(:default, "sqlite3:///#{File.expand_path(File.dirname(__FILE__))}/development.db")
end

helpers do
  # add your helpers here
end

get '/' do
  haml :root
end
