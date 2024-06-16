module SessionsHelper

  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end

  # 現在ログイン中のユーザーを返す（セッションにユーザーIDが存在する場合のみ）
  def current_user
    if session[:user_id]
      # 1回のリクエスト内におけるデータベースへの問い合わせが最初の1回だけで済むようUser.find_byの実行結果をインスタンス変数に保存して、次回から再利用
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end
end
