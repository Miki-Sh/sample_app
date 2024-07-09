require "test_helper"

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                      password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "nameが空欄になっている" do
    @user.name = "     "
    assert_not @user.valid?
  end

  test "emailが空欄になっている" do
    @user.email = "     "
    assert_not @user.valid?
  end

  test "nameが長すぎる" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "emailが長すぎる" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "email validationが有効なアドレスを受け入れる" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validationが無効なアドレスを拒否する" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "重複するemailアドレスを拒否するか" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  test "emailアドレスを小文字で保存しているか" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "パスワードが空文字でないことを確認できているか" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "passwordの最小文字数を指定できているか" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "記憶ダイジェストを持たないユーザーの場合、authenticated?はfalseを返す" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "ユーザーが削除されたときに、そのユーザーに紐付いたマイクロポストも一緒に削除される" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "ユーザーをフォロー/フォロー解除する" do
    michael = users(:michael)
    archer  = users(:archer)
    assert_not michael.following?(archer)
    michael.follow(archer)
    assert michael.following?(archer)
    michael.unfollow(archer)
    assert_not michael.following?(archer)
    # ユーザーは自分自身をフォローできない
    michael.follow(michael)
    assert_not michael.following?(michael)
  end
end
