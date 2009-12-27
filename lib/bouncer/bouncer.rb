module Sinatra
  module Bouncer
    module Helpers
      def confirmation_link(user)
        "http://localhost:4567/confirm/#{user.confirm_token}"
      end
    end

    def self.registered(app)
      get '/signup' do
        haml :signup
      end

      post '/signup' do
        user = User.new(params[:user])
        if user.save
          flash[:notice] = "hooray"
          Pony.mail(:to => user.email, :from => "no-reply@example.com", :body => confirmation_link(user))
          redirect "/"
        else
          flash[:error] = user.errors.first
          redirect "/signup"
        end
      end
    end
  end

  register Bouncer
end
