module Sinatra
  module Doorman
    COOKIE_KEY = "sinatra.doorman.remember"

    use Rack::Session::Cookie
    use Rack::Flash
    use Rack::Cookies
    use Warden::Manager do |manager|
      manager.failure_app = lambda { |env|
        env['x-rack.flash'][:error] = "You need to be authenticated to access this page"
        [302, { 'Location' => '/login' }, ['']] 
      }
      manager.default_strategies :remember_me

      manager.strategies.add(:password) do
        def valid?
          params['user'] && params['user']['login'] && params['user']['password']
        end

        def authenticate!
          user = User.authenticate(params['user']['login'], params['user']['password'])
          if user.nil?
            errors.add(:authenticate, "invalid login/password")
          elsif !user.confirmed
            errors.add(:authenticate, "email not confirmed")
          else   #confirmed
            user.remembered_password!
            if params['user']['remember_me']
              user.remember_me!
              env['rack.cookies'][COOKIE_KEY] = { :value => user.remember_token, :expires => Time.now + 7 * 24 * 3600, :path => '/' }
            end
            success!(user)
          end
        end
      end

      manager.strategies.add(:remember_me) do
        def valid?
          !!env['rack.cookies'][COOKIE_KEY]
        end

        def authenticate!
          token = env['rack.cookies'][COOKIE_KEY]
          return nil unless token
          user = User.first(:remember_token => token)
          if user.nil?
            env['rack.cookies'].delete(COOKIE_KEY)
          else
            user.remember_me!
            env['rack.cookies'][COOKIE_KEY] = { :value => user.remember_token, :expires => Time.now + 7 * 24 * 3600, :path => '/' }
            success!(user)
          end
        end
      end
    end

    class Warden::SessionSerializer
      def serialize(user); user.id; end
      def deserialize(id); User.get(id); end
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

      def confirmation_link(user)
        "http://#{env['HTTP_HOST']}/confirm/#{user.confirm_token}"
      end

      def reset_link(user)
        "http://#{env['HTTP_HOST']}/reset/#{user.confirm_token}"
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
          flash[:notice] = "Good job at signing up" + ' ' + user.confirm_token
          Pony.mail(:to => user.email, :from => "no-reply@#{env['SERVER_NAME']}", :body => confirmation_link(user))
          redirect "/"
        else
          flash[:error] = user.errors.first
          redirect "/signup"
        end
      end

      get '/confirm/:token/?' do
        redirect '/home' if authenticated?

        if params[:token].nil? || params[:token].empty?
          flash[:error] = "no token here"
          redirect '/'
        end

        user = User.first(:confirm_token => params[:token])
        if user.nil?
          flash[:error] = "Already confirmed or fake token"
        else
          user.confirm_email!
          flash[:notice] = 'Confirmed!'
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
        flash[:error] = 'login fail'
        redirect '/login'
      end

      get '/logout/?' do
        env['warden'].logout(:default)
        flash[:notice] = "You've managed to logout, great"
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
          flash[:error] = 'unknown login, try again'
          redirect '/forgot'
        end

        user.forgot_password!
        Pony.mail(:to => user.email, :from => "no-reply@#{env['SERVER_NAME']}", :body => reset_link(user))
        flash[:notice] = 'A reset password email has been sent to you'
        redirect '/login'
      end

      get '/reset/:token/?' do
        redirect '/home' if authenticated?

        if params[:token].nil? || params[:token].empty?
          flash[:error] = "no token here"
          redirect '/'
        end

        user = User.first(:confirm_token => params[:token])
        if user.nil?
          flash[:error] = "Password reset url no longer valid"
          redirect '/login'
        end

        haml :reset, :locals => { :confirm_token => user.confirm_token }
      end

      post '/reset' do
        redirect '/home' if authenticated?
        redirect '/' unless params['user']
        
        user = User.first(:confirm_token => params[:user][:confirm_token])
        if user.nil?
          flash[:error] = "Password reset url no longer valid"
          redirect '/login'
        end

        success = user.reset_password!(params['user']['password'], 
                                       params['user']['password_confirmation'])

        unless success
          flash[:error] = 'Passwords did not match'
          redirect "/reset/#{user.confirm_token}"
        end

        user.confirm_email!
        env['warden'].set_user(user)
        flash[:notice] = 'teh win'
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
