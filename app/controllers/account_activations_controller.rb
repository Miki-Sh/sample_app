class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by(email: params[:email])
     # !user.activated?　：既に有効になっているユーザーを誤って再度有効化しない　→　攻撃者がユーザーの有効化リンクを後から盗みだしてクリックし、本当のユーザーとしてログインするのを防ぐ
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.update_attribute(:activated,    true)
      user.update_attribute(:activated_at, Time.zone.now)
      log_in user
      flash[:success] = "アカウントが有効化されました!"
      redirect_to user
    else
      flash[:danger] = "無効な有効化リンクです"
      redirect_to root_url
    end
  end
end
