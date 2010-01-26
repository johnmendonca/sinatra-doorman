module Sinatra
  module Doorman
    COOKIE_KEY = "sinatra.doorman.remember"

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
          user.remembered_password!
          if params['user']['remember_me']
            user.remember_me!
            env['rack.cookies'][COOKIE_KEY] = { 
              :value => user.remember_token, 
              :expires => Time.now + 7 * 24 * 3600, 
              :path => '/' }
          end
          success!(user)
        end
      end
    end

    class RememberMeStrategy < Warden::Strategies::Base
      def valid?
        !!env['rack.cookies'][COOKIE_KEY]
      end

      def authenticate!
        token = env['rack.cookies'][COOKIE_KEY]
        return unless token
        user = User.first(:remember_token => token)
        if user.nil?
          env['rack.cookies'].delete(COOKIE_KEY)
        else
          user.remember_me!  # new token
          env['rack.cookies'][COOKIE_KEY] = { 
            :value => user.remember_token, 
            :expires => Time.now + 7 * 24 * 3600, 
            :path => '/' }
          success!(user)
        end
      end
    end

    class Warden::SessionSerializer
      def serialize(user); user.id; end
      def deserialize(id); User.get(id); end
    end

    use Rack::Session::Cookie
    use Rack::Flash
    use Rack::Cookies
    use Warden::Manager do |manager|
      manager.failure_app = lambda { |env|
        env['x-rack.flash'][:error] = :authentication_required
        [302, { 'Location' => '/login' }, ['']] 
      }
      manager.strategies.add(:password, PasswordStrategy) 
      manager.strategies.add(:remember_me, RememberMeStrategy) 
      manager.default_strategies :remember_me
    end

    Warden::Manager.before_logout do |user, proxy, opts|
      user.forget_me! if user
      proxy.env['rack.cookies'].delete(COOKIE_KEY)
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

      get '/signup/?' do
        redirect '/home' if authenticated?
        haml :signup
      end

      post '/signup' do
        redirect '/home' if authenticated?

        user = User.new(params[:user])
        if user.save
          flash[:notice] = Messages[:signup_success]
          flash[:notice] = 'Signed up: ' + user.confirm_token
          Pony.mail(
            :to => user.email, 
            :from => "no-reply@#{env['SERVER_NAME']}", 
            :body => token_link('confirm', user))
          redirect "/"
        else
          flash[:error] = user.errors.first
          redirect "/signup"
        end
      end

      get '/confirm/:token/?' do
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

      get '/login/?' do
        redirect '/home' if authenticated?
        haml :login
      end

      post '/login' do
        env['warden'].authenticate(:password)
        redirect '/home' if authenticated?
        redirect '/login'
      end

      get '/logout/?' do
        env['warden'].logout(:default)
        flash[:notice] = Messages[:logout_success]
        redirect '/login'
      end

      get '/forgot/?' do
        redirect '/home' if authenticated?
        haml :forgot
      end

      post '/forgot' do
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

      get '/reset/:token/?' do
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

      post '/reset' do
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

      get '/home/?' do
        env['warden'].authenticate!
        haml :home
      end
    end
  end

  register Doorman
end
