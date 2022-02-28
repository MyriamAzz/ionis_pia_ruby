class Admin::Settings::PaymentPlansController < AdminController
  load_and_authorize_resource param_method: :params_payment_plan

  def create
    plan = PaymentPlan.new(params_payment_plan)
    plan.school_program = current_user.user_admin.current_centre.school_program
    if plan.save
    else
      @error = true
    end
  end

  def destroy
    if @payment_plan.destroy
    else
      @error = true
    end
  end

  private

  def params_payment_plan
    params.require(:payment_plan).permit!
  end
end
