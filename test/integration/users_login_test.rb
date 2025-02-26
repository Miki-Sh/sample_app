require "test_helper"

class UsersLogin < ActionDispatch::IntegrationTest
  def setup
    # usersはfixtureのファイル名users.ymlを表し、:michaelというシンボルはusers.ymlに書いたユーザーを参照するためのキー
    @user = users(:michael)
  end
end

class InvalidPasswordTest < UsersLogin
  test "login path" do
    get login_path
    assert_template 'sessions/new'
  end

  test "有効なemail/無効なpasswordでログイン" do
    post login_path, params: { session: { email: @user.email, password: "invalid" } }
    assert_not is_logged_in?
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end
end

class ValidLogin < UsersLogin
  def setup
    super
    post login_path, params: { session: { email: @user.email, password: 'password' } }
  end
end

class ValidLoginTest < ValidLogin
  test "有効なログイン" do
    assert is_logged_in?
    assert_redirected_to @user
  end

  test "ログイン後にリダイレクトする" do
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
  end
end

class Logout < ValidLogin
  def setup
    super
    delete logout_path
  end
end

class LogoutTest < Logout
  test "ログアウト成功する" do
    assert_not is_logged_in?
    assert_response :see_other
    assert_redirected_to root_url
  end

  test "1つのタブですでにログアウトしたのに、もう1つのタブで再度ログアウトをクリックするユーザーをシミュレートする" do
    delete logout_path
    assert_redirected_to root_url
  end

  test "ログアウト後にリダイレクトする" do
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end
end

class RememberingTest < UsersLogin
  test "[remember me]チェックボックスをオンにしてログインする" do
    log_in_as(@user, remember_me: '1')
    assert_not cookies[:remember_token].blank?
  end

  test "[remember me]チェックボックスをオフにしてログインする" do
    # Cookieを保存してログイン
    log_in_as(@user, remember_me: '1')
    # Cookieが削除されていることを検証してからログイン
    log_in_as(@user, remember_me: '0')
    assert cookies[:remember_token].blank?
  end
end
