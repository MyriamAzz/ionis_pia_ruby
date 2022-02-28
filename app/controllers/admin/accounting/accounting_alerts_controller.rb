#encoding: utf-8
class Admin::Accounting::AccountingAlertsController < AdminController
  load_and_authorize_resource param_method: :params_accounting_alert

  def new
    @types = AccountingAlert.atypes.keys
    @types.delete("alert_payment")
    @types.delete("alert_late_registration")
  end

  def create
    alert = AccountingAlert.new(params_accounting_alert)
    alert.user = current_user
    if alert.save
    else
      @error = true
    end
  end

  def edit
    @types = AccountingAlert.atypes.keys
    if Rails.application.routes.recognize_path(request.referrer)[:controller] == "admin/manage/students"
      @student_view = true
    else
      @student_view = false
    end
  end

  def update
    @accounting_alert.assign_attributes(handled_by: current_user)
    @accounting_alert.assign_attributes(params_accounting_alert)
    if @accounting_alert.save
      if params[:student_view] == "true"
        @student = @accounting_alert.user_financier_subscription.user_financier.user
      end
    else
      @error = true
    end
  end

  def table_json
    alerts = AccountingAlert.where(centre_id: @centres.pluck(:id)).includes(:user, :user_financier_subscription).order(created_at: :desc)
    var = []
    alerts.each do |alert|
      var << { :id => alert.id, :centre => alert.centre.nom, :creator => (alert.user.nom_complet rescue "Système"), :user_financier_subscription_id => alert.user_financier_subscription_id, :student_uuid => alert.user_financier_subscription.user_financier.user.uuid, :student => alert.user_financier_subscription.user_financier.etu_nom_prenom, :atype => alert.atype, :status => alert.status, :updated_at => alert.updated_at.strftime("%d/%m/%y %H:%M") }
    end
    render json: var
  end

  private

  def params_accounting_alert
    params.require(:accounting_alert).permit!
  end
end
