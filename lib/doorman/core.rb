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
  end
end
