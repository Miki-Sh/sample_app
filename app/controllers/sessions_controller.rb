class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # セッション固定攻撃（攻撃者が既に持っているセッションidをユーザーに使わせるように仕向けることで、攻撃者がユーザーと意図的にセッションを共有して情報を奪う手法）への対策として、ユーザーがログインする直前にセッションを必ず即座にリセットする
      reset_session   # ログインの直前に必ずこれを書くこと
      log_in user
      redirect_to user
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
  end
end
