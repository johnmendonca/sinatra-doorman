module Sinatra
  module Doorman

    class Warden::SessionSerializer
      def serialize(user); user.id; end
      def deserialize(id); User.get(id); end
    end

    ##
    # Base Features:
    #   * Signup with Email Confirmation
    #   * Login/Logout
    ##

    class PasswordStrategy < Warden::Strategies::Base
      def valid?
        params['user'] && 
          params['user']['login'] &&
          params['user']['password']
      end

      def authenticate!
        user = User.authenticate(
          params['user']['login'], 
          params['user']['password'])

        if user.nil?
          fail!(:login_bad_credentials)
        elsif !user.confirmed
          fail!(:login_not_confirmed)
        else
          success!(user)
        end
      end
    end

    module Base
      module Helpers
        def authenticated?
          env['warden'].authenticated?
        end
        alias_method :logged_in?, :authenticated?

        def notify(type, message)
          message = Messages[message] if message.is_a?(Symbol)
          flash[type] = message
        end

        def token_link(type, user)
          "http://#{env['HTTP_HOST']}/#{type}/#{user.confirm_token}"
        end
      end

      def self.registered(app)
        app.helpers Helpers

        app.use Warden::Manager do |manager|
          manager.failure_app = lambda { |env|
            env['x-rack.flash'][:error] = Messages[:authentication_required]
            [302, { 'Location' => '/login' }, ['']] 
          }
        end

        Warden::Strategies.add(:password, PasswordStrategy) 

        app.get '/signup/?' do
          redirect '/home' if authenticated?
          haml :signup
        end

        app.post '/signup' do
          redirect '/home' if authenticated?

          user = User.new(params[:user])
          
          unless user.save
            notify :error, user.errors.first
            redirect back
          end

          notify :success, :signup_success
          notify :success, 'Signed up: ' + user.confirm_token
          Pony.mail(
            :to => user.email, 
            :from => "no-reply@#{env['SERVER_NAME']}", 
            :body => token_link('confirm', user))
          redirect "/"
        end

        app.get '/confirm/:token/?' do
          redirect '/home' if authenticated?

          if params[:token].nil? || params[:token].empty?
            notify :error, :confirm_no_token
            redirect '/'
          end

          user = User.first(:confirm_token => params[:token])
          if user.nil?
            notify :error, :confirm_no_user
          else
            user.confirm_email!
            notify :success, :confirm_success
          end
          redirect '/login'
        end

        app.get '/login/?' do
          redirect '/home' if authenticated?
          haml :login
        end

        app.post '/login' do
          env['warden'].authenticate(:password)
          redirect '/home' if authenticated?
          notify :error, env['warden'].message
          redirect back
        end

        app.get '/logout/?' do
          env['warden'].logout(:default)
          notify :success, :logout_success
          redirect '/login'
        end
      end
    end

    ##
    # Remember Me Feature
    ##

    COOKIE_KEY = "sinatra.doorman.remember"

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

    module RememberMe
      def self.registered(app)
        app.use Rack::Cookies

        Warden::Strategies.add(:remember_me, RememberMeStrategy)

        app.before do
          env['warden'].authenticate(:remember_me)
        end

        Warden::Manager.after_authentication do |user, auth, opts|
          if auth.winning_strategy.is_a?(RememberMeStrategy) ||
            (auth.winning_strategy.is_a?(PasswordStrategy) &&
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

    ##
    # Forgot Password Feature
    ##

    module ForgotPassword
      def self.registered(app)
        Warden::Manager.after_authentication do |user, auth, opts|
          # If the user requested a new password,
          # but then remembers and logs in,
          # then invalidate password reset token
          if auth.winning_strategy.is_a?(PasswordStrategy)
            user.remembered_password!
          end
        end

        app.get '/forgot/?' do
          redirect '/home' if authenticated?
          haml :forgot
        end

        app.post '/forgot' do
          redirect '/home' if authenticated?
          redirect '/' unless params['user']

          user = User.first_by_login(params['user']['login'])

          if user.nil?
            notify :error, :forgot_no_user
            redirect back
          end

          user.forgot_password!
          Pony.mail(
            :to => user.email, 
            :from => "no-reply@#{env['SERVER_NAME']}", 
            :body => token_link('reset', user))
          notify :success, :forgot_success
          redirect '/login'
        end

        app.get '/reset/:token/?' do
          redirect '/home' if authenticated?

          if params[:token].nil? || params[:token].empty?
            notify :error, :reset_no_token
            redirect '/'
          end

          user = User.first(:confirm_token => params[:token])
          if user.nil?
            notify :error, :reset_no_user
            redirect '/login'
          end

          haml :reset, :locals => { :confirm_token => user.confirm_token }
        end

        app.post '/reset' do
          redirect '/home' if authenticated?
          redirect '/' unless params['user']
          
          user = User.first(:confirm_token => params[:user][:confirm_token])
          if user.nil?
            notify :error, :reset_no_user
            redirect '/login'
          end

          success = user.reset_password!(
            params['user']['password'], 
            params['user']['password_confirmation'])

          unless success
            notify :error, :reset_unmatched_passwords
            redirect back
          end

          user.confirm_email!
          env['warden'].set_user(user)
          notify :success, :reset_success
          redirect '/home'
        end
      end
    end
  end
end
