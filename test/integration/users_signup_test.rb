require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end
 
  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      assert_select "form", :action => "/signup"
      post signup_path, params: { user: { name:  "",
                                         email: "user@invalid",
                                         password:              "foo",
                                         password_confirmation: "bar" } }
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation > div', 'The form contains 4 errors.'
    assert_select 'div#error_explanation > ul > li:nth-child(1)', "Name can't be blank"
    assert_select 'div#error_explanation > ul > li:nth-child(2)', "Email is invalid"
    assert_select 'div#error_explanation > ul > li:nth-child(3)', "Password confirmation doesn't match Password"
    assert_select 'div#error_explanation > ul > li:nth-child(4)', "Password is too short (minimum is 6 characters)"
  end

  test "valid signup information with account activation" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    # Try to log in before activation.
    log_in_as(user)
    assert_not is_logged_in?
    # Invalid activation token
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?
    # Valid token, wrong email
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    # Valid activation token
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated? 
    follow_redirect!
    assert_template 'users/show'
    assert_not flash.empty?
    assert flash[:success] == 'Account activated!'
    assert is_logged_in?
  end
end
