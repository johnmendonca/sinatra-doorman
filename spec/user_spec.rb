require "#{File.dirname(__FILE__)}/spec_helper"

# When object is first created (new?) it needs:
#   username, email, password, password_confirmation,
# After it has been saved once (!new?): 
#   salt, password_hash, confirm_token should have generated
#   password, password_confirmation are not required anymore
# Once created, generated values should not change
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
      
      describe 'then updated and saved twice' do
        before(:each) do
          @user.username = "newman"
          @user.save
        end

        # I do this twice to make sure the salt hash does not change with each save
        it 'should authenticate with the originally entered password' do
          # the password is still in the object from before
          password = @user.password
          @user.authenticated?(password).should == true
        end
      end
    end
  end
end
