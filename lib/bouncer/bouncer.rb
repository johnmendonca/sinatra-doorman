module Sinatra
  module Bouncer
    use Rack::Session::Cookie
    use Rack::Flash
    use Warden::Manager do |manager|
      manager.failure_app = lambda { |env|
        env['x-rack.flash'][:error] = "You need to be authenticated to access this page"
        [302, { 'Location' => '/login' }, ['']] 
      }
      manager.default_strategies :remember_me
      manager.default_serializers :session, :cookie

      manager.serializers.update(:session) do
        def serialize(user); user.id; end
        def deserialize(id); User.get(id); end
      end

      manager.serializers.update(:cookie) do
        def serialize(user); user.id; end
        def deserialize(token); User.get(id); end
      end

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
          else
            success!(user)
          end
        end
      end

      manager.strategies.add(:remember_me) do
        def valid?
          #if the right cookie is there
        end

        def authenticate!
          #look up user by token
          #nil, fail, clear token
          #user, success, new token
        end
      end
    end

    module Helpers
      def authenticated?
        env['warden'].authenticated?
      end
      alias_method :logged_in?, :authenticated?

      def confirmation_link(user)
        "http://#{env['HTTP_HOST']}/confirm/#{user.confirm_token}"
      end

      def message(type)
        case type
        when :signed_up then "Good job at signing up"
        when :confirm_token_invalid then "Already confirmed or fake token"
        end
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
          flash[:notice] = message(:signed_up) + ' ' + user.confirm_token
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
          flash[:error] = message(:confirm_token_invalid)
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
        #remember if checked
        redirect '/home' if authenticated?
        flash[:error] = 'login fail'
        redirect '/login'
      end

      get '/logout/?' do
        env['warden'].logout(:default)
        #forget me
        flash[:notice] = "You've managed to logout, great"
        redirect '/login'
      end

      get '/forgot/?' do
        redirect '/home' if authenticated?
        haml :forgot
      end

      post '/forgot' do
        #look up user
        #send them email
        redirect '/login'
      end

      get '/reset/:token/?' do
        redirect '/home' if authenticated?
        haml :reset
      end

      post '/reset' do
        redirect '/'
      end

      get '/home/?' do
        env['warden'].authenticate!
        haml :home
      end
    end
  end

  register Bouncer
end
