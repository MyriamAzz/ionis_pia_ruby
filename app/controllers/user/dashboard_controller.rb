class User::DashboardController < UserController
  authorize_resource :class => false

  def attestation_scolarite
    @data = UserFinancierSubscription.find(params[:user_financier_subscription_id])
    if @data.user_financier.user == current_user && (@data.apprentissage? or @data.is_frais_inscription_payed)
      @program = @data.user_financier.centre.school_program
      pdf = render_to_string pdf: "attestation_scolarite", template: "admin/manage/user_financier_subscriptions/attestation_scolarite_pdf.html.erb", margin: { top: 20 }
      file_name = "attestation_scolarite.pdf"
      send_data pdf, filename: file_name, :type => "application/pdf", :disposition => "attachment"
    else
      render :file => "#{Rails.root}/public/404.html", layout: false, status: :not_found
    end
  end
end
