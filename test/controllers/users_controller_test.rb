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

  test "ログインせずにindexアクションを実行すると、ログイン画面にリダイレクトする" do
    get users_path
    assert_redirected_to login_url
  end

  test "ログインせずにupdateアクションを実行するとログイン画面にリダイレクトする" do
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

  test "ログインせずにdestroyアクションを実行すると、ログイン画面にリダイレクトする" do
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_response :see_other
    assert_redirected_to login_url
  end

  test "管理者以外のユーザーがdestroyアクションを実行すると、ホーム画面にリダイレクトする" do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_response :see_other
    assert_redirected_to root_url
  end
end