module Sinatra
  module Bouncer
    module Helpers
      def confirmation_link(user)
        "http://#{env['HTTP_HOST']}/confirm/#{user.confirm_token}"
      end
    end

    def self.registered(app)
      app.helpers Helpers

      get '/signup' do
        haml :signup
      end

      post '/signup' do
        user = User.new(params[:user])
        if user.save
          flash[:notice] = "hooray"
          Pony.mail(:to => user.email, :from => "no-reply@#{env['SERVER_NAME']}", :body => confirmation_link(user))
          redirect "/"
        else
          flash[:error] = user.errors.first
          redirect "/signup"
        end
      end

      get '/confirm/:token' do
        #ensure actually signed up
        #give form
      end

      post '/confirm' do
        #authenticate user w/ token
        #confirm user
        #login user
      end
    end
  end

  register Bouncer
end
