require File.join(File.dirname(__FILE__), %w{ .. .. spec spec_helper } )

World do
  def app
    Sinatra::Application.new
  end

  include Rack::Test::Methods
  include Webrat::Methods
  include Webrat::Matchers
  include Pony::TestHelpers
end

Before do
  DataMapper.auto_migrate!
  reset_mailer
end
