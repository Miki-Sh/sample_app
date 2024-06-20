require "test_helper"

class SessionsHelperTest < ActionView::TestCase
  def setup
    @user = users(:michael) # fixtureでuser変数を定義する
    remember(@user)         # 渡されたユーザーをrememberメソッドで記憶する
  end

  test "sessionがnilの時、current_userが正しいユーザーを返す" do
    assert_equal @user, current_user # current_userが、渡されたユーザーと同じであることを確認する
    assert is_logged_in?
  end

  test "remember digestが違っている時、current_userがnilを返す" do
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    assert_nil current_user
  end
end