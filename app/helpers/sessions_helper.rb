module SessionsHelper

  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end

  # 永続的セッションのためにユーザーをデータベースに記憶する
  def remember(user)
    user.remember
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end
  
  # 現在ログイン中のユーザーを返す（sessionまたはcookiesにユーザーIDが存在する場合のみ）
  def current_user
    if (user_id = session[:user_id])
      # 1回のリクエスト内におけるデータベースへの問い合わせが最初の1回だけで済むようUser.find_byの実行結果をインスタンス変数に保存して、次回から再利用
      @current_user ||= User.find_by(id: user_id)
    # 記憶トークンcookieに対応するユーザーを返す
    elsif (user_id = cookies.encrypted[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end

  # 現在のユーザーをログアウトする
  def log_out
    reset_session
    @current_user = nil   # 安全のため
  end  
end
