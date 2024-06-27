require "test_helper"

class UsersSignup < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
  end
end

class UsersSignupTest < UsersSignup
  test "無効なユーザー登録のinformation" do
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name: "", email: "user@invalid", password: "foo", password_confirmation: "bar" } }
    end
    assert_response :unprocessable_entity
    assert_template 'users/new'
    # エラーメッセージをテストするためのテンプレート
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
  end

  test "有効なユーザー登録のinformation" do
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name: "Example User", email: "user@example.com", password: "password", password_confirmation: "password" } }
    end
    # 配信されたメッセージが1件かどうかを確認
    assert_equal 1, ActionMailer::Base.deliveries.size
  end
end

class AccountActivationTest < UsersSignup
  def setup
    super
    post users_path, params: { user: { name: "Example User", email: "user@example.com", password: "password", password_confirmation: "password" } }
    @user = assigns(:user)
  end

  test "すでに有効化されたuserではないか" do
    assert_not @user.activated?
  end

  test "アカウント有効化前にログインできない" do
    log_in_as(@user)
    assert_not is_logged_in?
  end

  test "無効なactivation tokenではログインできない" do
    get edit_account_activation_path("invalid token", email: @user.email)
    assert_not is_logged_in?
  end

  test "無効なメールアドレスではログインできない" do
    get edit_account_activation_path(@user.activation_token, email: 'wrong')
    assert_not is_logged_in?
  end

  test "有効なactivation tokenとメールアドレスの場合、ログイン成功する" do
    get edit_account_activation_path(@user.activation_token, email: @user.email)
    assert @user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
    assert_not flash.nil?
  end
end
