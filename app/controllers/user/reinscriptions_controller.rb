class User::ReinscriptionsController < ApplicationController
  skip_before_action :authenticate_user!

  def show
    @user = User.find_by_uuid(params[:id]) rescue nil
    if @user && @user.user?
      @subscription = fetch_subscription
      if !@subscription
        redirect_to root_path
      end
    else
      redirect_to root_path
    end
  end

  def confirm
    @user = User.find_by_uuid(params[:reinscription_id]) rescue nil
    if @user && @user.user? && !params[:payment_mode_inscription].blank? && !params[:modalite].blank? && !params[:payment_mode_scolarite].blank?
      @subscription = fetch_subscription
      if !@subscription
        @error = true
      else
        password = Devise.friendly_token.first(10)
        if @user.update(params_user) && @user.update(password: password)
          if @subscription.update(statut: :waiting_compta, etudiant_reinscription_done_date: DateTime.now, modalite: params[:modalite], payment_mode_inscription: params[:payment_mode_inscription], payment_mode_scolarite: params[:payment_mode_scolarite])
            @subscription.init_instalments_inscription
            UserMailer.reinscription_confirm_to_rf(@subscription, password).deliver_later
          else
            @error = true
          end
        else
          @error = true
        end
      end
    else
      @error = true
    end
  end

  private

  def params_user
    params.require(:user).permit!
  end

  def fetch_subscription
    return @user.user_financier.user_financier_subscriptions.where(statut: :waiting_user, s_type: :reinscription).last rescue false
  end
end
