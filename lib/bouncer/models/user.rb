module Sinatra
  module Bouncer
    class User
      include DataMapper::Resource

      property :id,                 Serial
      property :username,           String, :unique => true, :length => 1..23, :format => /^[a-zA-Z0-9\-_]*$/
      property :email,              String, :unique => true, :required => true, :format => :email_address
      property :password_hash,      String, :accessor => :protected
      property :salt,               String, :accessor => :protected

      property :confirmed,          Boolean, :writer => :protected
      property :confirm_token,      String, :writer => :protected
      property :remember_token,     String, :writer => :protected

      property :created_at,         DateTime
      property :last_login,         DateTime

      attr_accessor :password, :password_confirmation

      validates_length :password, :min => 4, :if => :new?
      validates_is_confirmed :password
      
      before :create do
        if valid?
          self.password_hash = encrypt(password)
          self.confirm_token = new_token
        end
      end

      def self.authenticate(login, password)
        #if login has @ symbol, treat as email address
        column = ( login =~ /@/ ? :email : :username )
        user = User.first(column => login)

        return user if user && user.authenticated?(password)
        return nil
      end

      def authenticated?(password)
        self.password_hash == encrypt(password)
      end

      def remember_me!
        self.remember_token = new_token
        save
      end

      def forget_me!
        self.remember_token = nil
        save
      end

      def confirm_email!
        self.confirmed    = true
        self.confirm_token = nil
        save
      end

      def forgot_password!
        self.confirm_token = new_token
        save
      end

      def reset_password!(new_password, new_password_confirmation)
        self.password              = new_password
        self.password_confirmation = new_password_confirmation
        if valid?
          self.password_hash = encrypt(password)
          save
        end
      end

      protected

      def salt
        if @salt.nil? || @salt.empty?
          secret    = Digest::SHA1.hexdigest("--#{Time.now.utc}--")
          self.salt = Digest::SHA1.hexdigest("--#{Time.now.utc}--#{secret}--")
        end
        @salt
      end

      def encrypt(string)
        Digest::SHA1.hexdigest("--#{salt}--#{string}--")
      end

      def new_token
        encrypt("--#{Time.now.utc}--")
      end
    end
  end
end
