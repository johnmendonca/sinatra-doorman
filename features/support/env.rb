require File.join(File.dirname(__FILE__), %w{ .. .. spec spec_helper } )

World do
  include Rack::Test::Methods
  include Webrat::Methods
  include Webrat::Matchers

  def app
    Sinatra::Application
  end
end
