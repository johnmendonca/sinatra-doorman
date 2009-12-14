require File.join(File.dirname(__FILE__), %w{ .. .. spec spec_helper } )

World do
  def app
    Sinatra::Application
  end

  include Rack::Test::Methods
  include Webrat::Methods
  include Webrat::Matchers
end

Before do
  DataMapper.auto_migrate!
end
