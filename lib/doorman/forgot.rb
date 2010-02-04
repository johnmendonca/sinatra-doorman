module Sinatra
  module Doorman
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
