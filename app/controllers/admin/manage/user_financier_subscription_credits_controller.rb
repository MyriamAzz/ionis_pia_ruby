class Admin::Manage::UserFinancierSubscriptionCreditsController < AdminController
  load_and_authorize_resource param_method: :params_user_financier_subscription_credit

  def new
    @user_financier_subscription = UserFinancierSubscription.find(params[:user_financier_subscription_id])
  end

  def create
    @user_financier_subscription = UserFinancierSubscription.find(params[:user_financier_subscription_id])
    @credit = UserFinancierSubscriptionCredit.new(params_user_financier_subscription_credit)
    @credit.user_financier_subscription = @user_financier_subscription
    @credit.creator = current_user
    if @credit.save
      @student = User.find_by_uuid(params[:student_id])
      @error = false
    else
      @error = true
    end
  end

  private

  def params_user_financier_subscription_credit
    params.require(:user_financier_subscription_credit).permit!
  end
end
