module Sinatra
  module Doorman

    class Warden::SessionSerializer
      def serialize(user); user.id; end
      def deserialize(id); User.get(id); end
    end

    #
    # Core functionality - includes signup with email confirmation
    # and login/logout
    #

    module Core
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
            env['x-rack.flash'][:error] = Messages[:login_bad_credentials]
          elsif !user.confirmed
            env['x-rack.flash'][:error] = Messages[:login_not_confirmed]
          else  # confirmed
            success!(user)
          end
        end
      end

      module Helpers
        def authenticated?
          env['warden'].authenticated?
        end
        alias_method :logged_in?, :authenticated?

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
            flash[:error] = user.errors.first
            redirect back
          end

          flash[:notice] = Messages[:signup_success]
          flash[:notice] = 'Signed up: ' + user.confirm_token
          Pony.mail(
            :to => user.email, 
            :from => "no-reply@#{env['SERVER_NAME']}", 
            :body => token_link('confirm', user))
          redirect "/"
        end

        app.get '/confirm/:token/?' do
          redirect '/home' if authenticated?

          if params[:token].nil? || params[:token].empty?
            flash[:error] = Messages[:confirm_no_token]
            redirect '/'
          end

          user = User.first(:confirm_token => params[:token])
          if user.nil?
            flash[:error] = Messages[:confirm_no_user]
          else
            user.confirm_email!
            flash[:notice] = Messages[:confirm_success]
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
          redirect '/login'
        end

        app.get '/logout/?' do
          env['warden'].logout(:default)
          flash[:notice] = Messages[:logout_success]
          redirect '/login'
        end
      end
    end

    #
    # Remember Me
    #

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

    #
    # Forgot Password
    #

    module ForgotPassword
      def self.registered(app)
        Warden::Manager.after_authentication do |user, auth, opts|
          # If the user requested a new password,
          # but then remembers and logs in,
          # then invalidate password reset token
          if auth.winning_strategy.is_a?(Core::PasswordStrategy)
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
            flash[:error] = Messages[:forgot_no_user]
            redirect '/forgot'
          end

          user.forgot_password!
          Pony.mail(
            :to => user.email, 
            :from => "no-reply@#{env['SERVER_NAME']}", 
            :body => token_link('reset', user))
          flash[:notice] = Messages[:forgot_success]
          redirect '/login'
        end

        app.get '/reset/:token/?' do
          redirect '/home' if authenticated?

          if params[:token].nil? || params[:token].empty?
            flash[:error] = Messages[:reset_no_token]
            redirect '/'
          end

          user = User.first(:confirm_token => params[:token])
          if user.nil?
            flash[:error] = Messages[:reset_no_user]
            redirect '/login'
          end

          haml :reset, :locals => { :confirm_token => user.confirm_token }
        end

        app.post '/reset' do
          redirect '/home' if authenticated?
          redirect '/' unless params['user']
          
          user = User.first(:confirm_token => params[:user][:confirm_token])
          if user.nil?
            flash[:error] = Messages[:reset_no_user]
            redirect '/login'
          end

          success = user.reset_password!(
            params['user']['password'], 
            params['user']['password_confirmation'])

          unless success
            flash[:error] = Messages[:reset_unmatched_passwords]
            redirect "/reset/#{user.confirm_token}"
          end

          user.confirm_email!
          env['warden'].set_user(user)
          flash[:notice] = Messages[:reset_success]
          redirect '/home'
        end
      end
    end
  end
end
