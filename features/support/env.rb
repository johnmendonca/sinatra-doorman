require File.join(File.dirname(__FILE__), %w{ .. .. spec spec_helper } )

World do
  def app
    Sinatra::Application.new
  end

  include Rack::Test::Methods
  include Webrat::Methods
  include Webrat::Matchers
  include EmailSpec::Helpers
  include EmailSpec::Matchers
end

Before do
  DataMapper.auto_migrate!
end
