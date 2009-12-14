module Sinatra
  module Bouncer
    class User
      include DataMapper::Resource

      property :id,                 Serial
      property :username,           String, :length => 1..23
      property :email,              String, :required => true, :format => :email_address
      property :password_hash,      String, :accessor => :protected
      property :salt,               String, :accessor => :protected

      property :remember_token,     String, :accessor => :protected
      property :confirm_token,      String, :accessor => :protected
      property :confirmed,          Boolean, :writer => :protected

      property :created_at,         DateTime
      property :last_login,         DateTime

      attr_accessor :password, :password_confirmation
      validates_length :password, :password_confirmation, :min => 4, :if => :new?
      validates_is_confirmed :password, :password_confirmation
      
      before :create do
        generate_password_hash
        generate_confirm_token
      end

      def authenticated?(password)
        self.password_hash == encrypt(password)
      end

      def remember_me!
        self.remember_token = encrypt("--#{Time.now.utc}--#{password}--#{id}--")
        save(false)
      end

      def confirm_email!
        self.confirmed    = true
        self.confirm_token = nil
        save(false)
      end

      def forgot_password!
        generate_confirm_token
        save(false)
      end

      def update_password(new_password, new_password_confirmation)
        self.password              = new_password
        self.password_confirmation = new_password_confirmation
        if valid?
          self.confirm_token = nil
        end
        save
      end

      protected

      def salt
        if @salt.nil? || @salt.empty?
          self.salt = Digest::SHA1.hexdigest("--#{Time.now.utc}--#{password}--")
        end
        @salt
      end

      def encrypt(string)
        Digest::SHA1.hexdigest("--#{salt}--#{string}--")
      end

      def generate_confirm_token
        self.confirm_token = encrypt("--#{Time.now.utc}--#{password}--")
      end

      def generate_password_hash
        unless password.nil? || password.empty?
          self.password_hash = encrypt(password)
        end
      end
    end
  end
end
