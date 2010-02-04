module Sinatra
  module Doorman
    COOKIE_KEY = "sinatra.doorman.remember"

    module RememberMe
      class RememberMeStrategy < Warden::Strategies::Base
        def valid?
          !!env['rack.cookies'][COOKIE_KEY]
        end

        def authenticate!
          token = env['rack.cookies'][COOKIE_KEY]
          return unless token
          user = User.first(:remember_token => token)
          env['rack.cookies'].delete(COOKIE_KEY) and return if user.nil?
          success!(user)
        end
      end

      def self.registered(app)
        app.use Rack::Cookies

        Warden::Strategies.add(:remember_me, RememberMeStrategy)

        app.before do
          env['warden'].authenticate(:remember_me)
        end

        Warden::Manager.after_authentication do |user, auth, opts|
          if auth.winning_strategy.is_a?(RememberMeStrategy) ||
            (auth.winning_strategy.is_a?(Core::PasswordStrategy) &&
               auth.params['user']['remember_me'])
            user.remember_me!  # new token
            auth.env['rack.cookies'][COOKIE_KEY] = { 
              :value => user.remember_token, 
              :expires => Time.now + 7 * 24 * 3600, 
              :path => '/' }
          end
        end

        Warden::Manager.before_logout do |user, auth, opts|
          user.forget_me! if user
          auth.env['rack.cookies'].delete(COOKIE_KEY)
        end
      end
    end
  end
end
