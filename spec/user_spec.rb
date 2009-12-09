require "#{File.dirname(__FILE__)}/spec_helper"

describe 'user' do
  before(:each) do
    @user = User.new(:username => 'test user')
  end

  specify 'should be valid' do
    @user.should be_valid
  end

  specify 'should require a username' do
    @user = User.new
    @user.should_not be_valid
    @user.errors[:name].should include("Name must not be blank")
  end
end
