class Admin::Manage::UserFinancierMandatesController < AdminController
  load_and_authorize_resource

  def download
    @mandate = UserFinancierMandate.find(params[:user_financier_mandate_id])
    @user_financier = @mandate.user_financier

    # if !@user_financier.centre.ics.blank?
    #   @creancier = @user_financier.centre
    # else
    #   @creancier = @user_financier.centre.school_program
    # end

    if !@user_financier.centre.ics.blank?
      @creancier = @user_financier.centre
    elsif !@user_financier.centre.school_program.ics.blank?
      @creancier = @user_financier.centre.school_program
    end

    pdf = render_to_string pdf: "mandat_sepa", template: "admin/manage/user_financier_mandates/mandat_sepa_pdf.html.erb", margin: { top: 20 }
    file_name = "MANDAT_SEPA_#{@mandate.rum}.pdf"
    send_data pdf, :filename => file_name, :type => "application/pdf", :disposition => "attachment"
  end
end
