#encoding: utf-8
class Admin::Manage::UserFinancierSubscriptionInstalmentsController < AdminController
  load_and_authorize_resource

  def show
    @instalment = @user_financier_subscription_instalment
  end

  def init_retry
    @instalment = @user_financier_subscription_instalment
  end

  def submit_retry
    @instalment = @user_financier_subscription_instalment
    if @instalment.apply_retry(params[:user_financier_subscription_instalment][:echeance], @instalment.montant)
      @student = User.find(params[:student_id])
    else
      @error = true
    end
    if request.referrer.include? "admin/compta"
      @compta = true
    end
  end

  def canceled
    if @user_financier_subscription_instalment.can_canceled_closure && @user_financier_subscription_instalment.update(statut: :canceled)
      @student = User.find(params[:student_id])
    else
      @error = true
    end
  end

  def rescheduled
    if (@user_financier_subscription_instalment.failed? or @user_financier_subscription_instalment.refused?) && @user_financier_subscription_instalment.update(rescheduled: true)
      @student = User.find(params[:student_id])
    else
      @error = true
    end
  end

  def force_turnover
    if @user_financier_subscription_instalment.can_force_turnover && @user_financier_subscription_instalment.force_turnover && @user_financier_subscription_instalment.update(can_force_turnover: false) &&
       @student = User.find(params[:student_id])
    else
      @error = true
    end
  end

  def facture_pdf
    @data = @user_financier_subscription_instalment
    pdf = render_to_string pdf: "facture", template: "admin/manage/user_financier_subscription_instalments/facture_pdf.html.erb", margin: { top: 20 }
    file_name = "facture_acquittée_#{@data.facture}.pdf"
    send_data pdf, filename: file_name, :type => "application/pdf", :disposition => "attachment"
  end
end
