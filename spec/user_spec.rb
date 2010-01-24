require "#{File.dirname(__FILE__)}/spec_helper"

#publicize some values for testing
class Sinatra::Bouncer::User
  def pub_password_hash; @password_hash; end
  def pub_salt; @salt; end
end

# new?:
#   username, email, password, password_confirmation all required
# !new?: 
#   salt, password_hash, confirm_token should have been generated
#   password, password_confirmation are not required but should match if present
# 
describe 'A new user object' do
  before(:each) do
    @user = Sinatra::Bouncer::User.new
  end

  it "should be invalid" do
    @user.should_not be_valid
  end

  describe "containing all user input fields" do
    before(:each) do
      @user.username = "Example"
      @user.email = "joe@example.com"
      @user.password = "pastworm"
      @user.password_confirmation = "pastworm"
    end

    it 'should be new and valid' do
      @user.should be_new
      @user.should be_valid
    end

    it 'should invalidate without username' do
      @user.username = ""
      @user.should_not be_valid
      @user.errors[:username].should_not be_nil
    end

    it 'should invalidate with unallowed username' do
      @user.username = "contact"
      @user.should_not be_valid
      @user.errors[:username].should_not be_nil
    end

    it 'should invalidate with unallowed characters in the username' do
      @user.username = "foo@example.com"
      @user.should_not be_valid
      @user.errors[:username].should_not be_nil
    end

    it 'should invalidate with lengthy username' do
      @user.username = "joetheplumberisthemanwiththeplumbingplan"
      @user.should_not be_valid
      @user.errors[:username].should_not be_nil
    end

    it 'should invalidate without email' do
      @user.email = ""
      @user.should_not be_valid
      @user.errors[:email].should_not be_nil
    end

    it 'should invalidate with malformed email' do
      @user.email = "internet.com"
      @user.should_not be_valid
      @user.errors[:email].should_not be_nil
    end

    it 'should invalidate without password' do
      @user.password = ""
      @user.should_not be_valid
      @user.errors[:password].should_not be_nil
    end

    it 'should invalidate without password_confirmation' do
      @user.password_confirmation = ""
      @user.should_not be_valid
      @user.errors[:password_confirmation].should_not be_nil
    end

    it 'should invalidate with unmatching passwords' do
      @user.password_confirmation = "hello"
      @user.should_not be_valid
      @user.errors[:password_confirmation].should_not be_nil
    end

    it 'should invalidate with short password' do
      @user.password = "hi"
      @user.password_confirmation = "hi"
      @user.should_not be_valid
      @user.errors[:password].should_not be_nil
    end

    it 'should not have a salt or password_hash' do
      @user.pub_salt.should be_nil
      @user.pub_password_hash.should be_nil
    end

    describe 'saved once' do
      before(:each) do
        @user.save
      end

      it 'should not be new but valid' do
        @user.should_not be_new
        @user.should be_valid
      end

      it 'should authenticate with the originally entered password' do
        # the password is still in the object from before
        password = @user.password
        @user.authenticated?(password).should == true
      end

      it 'should be valid without a password' do
        @user.password = ""
        @user.should be_valid
      end

      it 'should be invalid with unmatching passwords' do
        @user.password = "pastworm"
        @user.password_confirmation = "dirtworm"
        @user.should_not be_valid
      end

      it 'should have a salt and password_hash' do
        @user.pub_salt.should_not be_nil
        @user.pub_salt.length.should > 20
        @user.pub_password_hash.should_not be_nil
        @user.pub_password_hash.length.should > 20
      end

      it 'should have the same salt after subsequent update/saves' do
        old_salt = @user.pub_salt
        @user.username = 'newman'
        @user.save.should == true
        @user.pub_salt.should == old_salt
      end
      
      it 'should have the same password_hash after subsequent update/saves' do
        old_hash = @user.pub_password_hash
        @user.username = 'newman'
        @user.save.should == true
        @user.pub_password_hash.should == old_hash
      end
    end
  end
end

describe 'User.authenticate' do
  before(:each) do
    user = Sinatra::Bouncer::User.new(:username => 'dave', :email => 'dave@example.com', :password => 'password', :password_confirmation => 'password')
    user.save.should == true
    user = Sinatra::Bouncer::User.new(:username => 'will', :email => 'will@example.com', :password => 'secret', :password_confirmation => 'secret')
    user.save.should == true
  end

  it 'should return a user by username' do
    user = Sinatra::Bouncer::User.authenticate('dave', 'password')
    user.should_not be_nil
    user.email.should == 'dave@example.com'
  end

  it 'should return a user by email address' do
    user = Sinatra::Bouncer::User.authenticate('will@example.com', 'secret')
    user.should_not be_nil
    user.username.should == 'will'
  end

  it 'should return nil with wrong password' do
    user = Sinatra::Bouncer::User.authenticate('will@example.com', 'uhhhh')
    user.should be_nil
  end
end
