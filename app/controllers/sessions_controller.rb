class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user && @user.authenticate(params[:session][:password])
      if @user.activated?
        forwarding_url = session[:forwarding_url]
        # セッション固定攻撃（攻撃者が既に持っているセッションidをユーザーに使わせるように仕向けることで、攻撃者がユーザーと意図的にセッションを共有して情報を奪う手法）への対策として、ユーザーがログインする直前にセッションを必ず即座にリセットする
        reset_session   # ログインの直前に必ずこれを書くこと
        params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
        log_in @user
        redirect_to forwarding_url || @user
      else
        message  = "アカウントが有効化されていません。 "
        message += "メールを確認して、有効化リンクをクリックしてください。"
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash.now[:danger] = "無効なemail/passwordの組み合わせです"
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    log_out if logged_in?
      # RailsでTurboを使うときは、303 See Otherステータスを指定することで、DELETEリクエスト後のリダイレクトが正しく振る舞うようにする必要がある
    redirect_to root_url, status: :see_other
  end
end
