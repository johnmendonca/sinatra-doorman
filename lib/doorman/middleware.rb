require 'sinatra/base'

module Sinatra
  module Doorman
    class Middleware < Sinatra::Base
      register Base
      register RememberMe
      register ForgotPassword
    end
  end
end
