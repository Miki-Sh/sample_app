require "test_helper"

class PasswordResets < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end
end

class ForgotPasswordFormTest < PasswordResets
  test "パスワードリセットパス" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    assert_select 'input[name=?]', 'password_reset[email]'
  end

  test "無効なメールアドレスでのリセットパス" do
    post password_resets_path, params: { password_reset: { email: "" } }
    assert_response :unprocessable_entity
    assert_not flash.empty?
    assert_template 'password_resets/new'
  end
end

class PasswordResetForm < PasswordResets
  def setup
    super
    @user = users(:michael)
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    @reset_user = assigns(:user)
  end
end

class PasswordFormTest < PasswordResetForm
  test "有効なメールアドレスでのパスワードリセット" do
    assert_not_equal @user.reset_digest, @reset_user.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "間違ったメールアドレスでのパスワードリセット" do
    get edit_password_reset_path(@reset_user.reset_token, email: "")
    assert_redirected_to root_url
  end

  test "有効化されていないユーザーでのパスワードリセット" do
    @reset_user.toggle!(:activated)
    get edit_password_reset_path(@reset_user.reset_token,
                                 email: @reset_user.email)
    assert_redirected_to root_url
  end

  test "正しいメールアドレス、間違ったトークンでのパスワードリセット" do
    get edit_password_reset_path('wrong token', email: @reset_user.email)
    assert_redirected_to root_url
  end

  test "正しいメールアドレスと正しいトークンでのパスワードリセット" do
    get edit_password_reset_path(@reset_user.reset_token,
                                 email: @reset_user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", @reset_user.email
  end
end

class PasswordUpdateTest < PasswordResetForm
  test "無効なパスワードとパスワード確認でのupdate" do
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "barquux" } }
    assert_select 'div#error_explanation'
  end

  test "空のパスワードでのupdate" do
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password:              "",
                            password_confirmation: "" } }
    assert_select 'div#error_explanation'
  end

  test "有効なパスワードとパスワード確認でのupdate" do
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "foobaz" } }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to @reset_user
  end
end

class ExpiredToken < PasswordResets
  def setup
    super
    # パスワードリセットのトークンを作成する
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    @reset_user = assigns(:user)
    # トークンを手動で失効させる
    @reset_user.update_attribute(:reset_sent_at, 3.hours.ago)
    # ユーザーのパスワードの更新を試みる
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password: "foobar", password_confirmation: "foobar" } }
  end
end

class ExpiredTokenTest < ExpiredToken
  test "password-resetページにリダイレクトする" do
    assert_redirected_to new_password_reset_url
  end

  test "password-resetページに'expired'という単語が含まれている" do
    follow_redirect!
    assert_match /期限切れ/, response.body
  end
end