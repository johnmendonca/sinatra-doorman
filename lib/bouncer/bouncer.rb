module Sinatra
  module Bouncer
    module Helpers
    end

    def self.registered(app)
      get '/signup' do
        haml :signup
      end

      post '/signup' do
        user = User.new(params[:user])
        unless user.save
          flash[:error] = user.errors.first
          redirect "/signup"
        end
        redirect "/"
      end
    end
  end

  register Bouncer
end
