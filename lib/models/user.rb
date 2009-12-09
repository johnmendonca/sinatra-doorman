class User
  include DataMapper::Resource

  property :id,                 Serial
  property :username,           String
  property :email,              String
  property :password_hash,      String, :accessor => :private
  property :salt,               String, :accessor => :private
  property :created_at,         DateTime

  property :confirm_token,      String, :accessor => :private
  property :confirmed,          Boolean

  property :remember_token,     String, :accessor => :private
  property :last_login,         DateTime

  attr_accessor :password, :password_confirmation
  
  before :save do
    initialize_salt
    encrypt_password
    initialize_confirm_token
  end

  # Set the remember token.
  #
  # @example
  #   user.remember_me!
  #   cookies[:remember_token] = {
  #     :value   => user.remember_token,
  #     :expires => 1.year.from_now.utc
  #   }
  def remember_me!
    self.remember_token = encrypt("--#{Time.now.utc}--#{password}--#{id}--")
    save(false)
  end

  # Confirm my email.
  #
  # @example
  #   user.confirm_email!
  def confirm_email!
    self.confirmed    = true
    self.confirm_token = nil
    save(false)
  end

  # Mark my account as forgotten password.
  #
  # @example
  #   user.forgot_password!
  def forgot_password!
    generate_confirm_token
    save(false)
  end

  # Update my password.
  #
  # @param [String, String] password and password confirmation
  # @return [true, false] password was updated or not
  # @example
  #   user.update_password('new-password', 'new-password')
  def update_password(new_password, new_password_confirmation)
    self.password              = new_password
    self.password_confirmation = new_password_confirmation
    if valid?
      self.confirm_token = nil
    end
    save
  end

  protected

  def initialize_salt
    if new_record?
      self.salt = generate_hash("--#{Time.now.utc}--#{password}--")
    end
  end

  def generate_confirm_token
    self.confirm_token = encrypt("--#{Time.now.utc}--#{password}--")
  end

  def initialize_confirm_token
    generate_confirm_token if new_record?
  end

  def password_required?
    password_hash.blank? || !password.blank?
  end
  
  def generate_hash(string)
    Digest::SHA1.hexdigest(string)
  end

  def encrypt(string)
    generate_hash("--#{salt}--#{string}--")
  end

  def encrypt_password
    return if password.blank?
    self.password_hash = encrypt(password)
  end
end
