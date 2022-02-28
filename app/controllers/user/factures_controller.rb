#encoding: utf-8
class User::FacturesController < UserController
  load_and_authorize_resource class: false

  def facture_echeance_pdf
    @data = UserFinancierSubscriptionInstalment.find(params[:user_financier_subscription_instalment_id])
    if @data.user_financier_subscription.user_financier.user == current_user
      pdf = render_to_string pdf: "facture", template: "admin/manage/user_financier_subscription_instalments/facture_pdf.html.erb", margin: { top: 20 }
      file_name = "facture_acquittée_#{@data.facture}.pdf"
      send_data pdf, filename: file_name, :type => "application/pdf", :disposition => "attachment"
    else
      render :file => "#{Rails.root}/public/404.html", layout: false, status: :not_found
    end
  end

  def facture_proforma_pdf
    @data = UserFinancierSubscription.find(params[:user_financier_subscription_id])
    if @data.user_financier.user == current_user
      pdf = render_to_string pdf: "facture", template: "admin/manage/user_financier_subscriptions/facture_proforma_pdf.html.erb", margin: { top: 20 }
      file_name = "facture_proforma.pdf"
      send_data pdf, filename: file_name, :type => "application/pdf", :disposition => "attachment"
    else
      render :file => "#{Rails.root}/public/404.html", layout: false, status: :not_found
    end
  end

  def facture_pdf
    @data = UserFinancierSubscription.find(params[:user_financier_subscription_id])
    if @data.user_financier.user == current_user
      pdf = render_to_string pdf: "facture", template: "admin/manage/user_financier_subscriptions/facture_pdf.html.erb", margin: { top: 20 }
      file_name = "facture.pdf"
      send_data pdf, filename: file_name, :type => "application/pdf", :disposition => "attachment"
    else
      render :file => "#{Rails.root}/public/404.html", layout: false, status: :not_found
    end
  end
end
