module Sinatra
  module Bouncer
    use Rack::Session::Cookie
    use Rack::Flash
    use Warden::Manager do |manager|
      manager.failure_app = lambda { |env|
        env['x-rack.flash'][:error] = "You need to be authenticated to access this page"
        [302, { 'Location' => '/login' }, ['']] 
      }
      manager.default_serializers :session, :cookie

      manager.serializers.update(:session) do
        def serialize(user)
          user.id
        end

        def deserialize(id)
          User.get(id)
        end
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
    end

    module Helpers
      def logged_in?
        env['warden'].authenticated?
      end

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
        redirect '/home' if logged_in?
        haml :signup
      end

      post '/signup' do
        redirect '/home' if logged_in?

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
        redirect '/home' if logged_in?

        if params[:token].nil? || params[:token].empty?
          flash[:error] = "no token here"
          redirect '/'
        end

        user = User.first(:confirm_token => params[:token])
        if user.nil?
          flash[:error] = message(:confirm_token_invalid)
          redirect '/login'
        else
          haml :confirm, :locals => { :confirm_token => user.confirm_token }
        end
      end

      post '/confirm' do
        redirect '/home' if logged_in?

        user = User.authenticate(params[:user][:username], params[:user][:password])
        
        if user.nil?
          flash[:error] = 'bad credentials'
          redirect '/confirm/' + params[:user][:confirm_token]
        end

        unless user.confirm_token == params[:user][:confirm_token]
          flash[:error] = message(:confirm_token_invalid)
          redirect '/'
        end

        user.confirm_email!
        env['warden'].set_user(user)
        flash[:notice] = 'Confirmed!'
        redirect '/home'
      end

      get '/login/?' do
        redirect '/home' if logged_in?
        haml :login
      end

      post '/login' do
        env['warden'].authenticate(:password)
        redirect '/home' if logged_in?
        flash[:error] = 'login fail'
        redirect '/login'
      end

      get '/home/?' do
        env['warden'].authenticate!
        haml :home
      end

      get '/logout/?' do
        env['warden'].logout(:default)
        flash[:notice] = "You've managed to logout, great"
        redirect '/login'
      end
    end
  end

  register Bouncer
end
