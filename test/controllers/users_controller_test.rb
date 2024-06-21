require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get signup_path
    assert_response :success
  end

  test "ログインしていない時、indexにリダイレクトする" do
    get users_path
    assert_redirected_to login_url
  end
end
