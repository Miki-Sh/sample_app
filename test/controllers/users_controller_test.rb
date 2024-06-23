require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user       = users(:michael)
    @other_user = users(:archer)
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  test "ログインしていない時、indexにリダイレクトする" do
    get users_path
    assert_redirected_to login_url
  end

  test "ログインしていない時、updateにリダイレクトする" do
    patch user_path(@user), params: { user: { name: @user.name, email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "web経由でadmin属性が編集されてはいけない" do
    log_in_as(@other_user)
    assert_not @other_user.admin?
    patch user_path(@other_user), params: { user: { password: "password", password_confirmation: "password", admin: true } }
    assert_not @other_user.reload.admin?
  end
end
