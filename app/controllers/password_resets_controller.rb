class PasswordResetsController < ApplicationController
  before_action :get_user,   only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "パスワードリセット方法を記載したメールを送信しました"
      redirect_to root_url
    else
      flash.now[:danger] = "メールアドレスが見つかりません"
      render 'new', status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty?                  # （3）への対応
      @user.errors.add(:password, "パスワードは空欄にできません")
      render 'edit', status: :unprocessable_entity
    elsif @user.update(user_params)                     # （4）への対応
      @user.forget   # ユーザーのリメンバーダイジェストを無効にする
      reset_session  # 現在のセッションをリセットする
      log_in @user   # 新しいセッションでユーザーをログインさせる
      flash[:success] = "パスワードはリセットされました"
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity      # （2）への対応
    end
  end

  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    def get_user
      @user = User.find_by(email: params[:email])
    end

    # beforeフィルタ

    # 有効なユーザーかどうか確認する
    def valid_user
      unless (@user && @user.activated? &&
              @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    # トークンが期限切れかどうか確認する
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "パスワードリセットの有効期限切れです"
        redirect_to new_password_reset_url
      end
    end
end