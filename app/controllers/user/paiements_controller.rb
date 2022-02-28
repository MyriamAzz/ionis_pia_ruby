class User::PaiementsController < ApplicationController
  authorize_resource :class => false

  def edit_rib
    @user_financier_rib = current_user.user_financier.user_financier_rib
  end

  def update_rib
    @user_financier_rib = current_user.user_financier.user_financier_rib
    if @user_financier_rib.update(params_rib)
    else
      @error = true
    end
  end

  def new_mandate
    @mandate = UserFinancierMandate.new
  end

  def validate_mandate
    @mandate = UserFinancierMandate.new(params_mandate)
    @mandate.nom = @current_user.user_financier.nom
    @mandate.prenom = @current_user.user_financier.prenom
    @mandate.adresse = @current_user.user_financier.adresse
    @mandate.cp = @current_user.user_financier.code_postal
    @mandate.ville = @current_user.user_financier.ville
    @mandate.email = @current_user.email
    @mandate.pays = @current_user.user_financier.pays
    @mandate.user_financier = @current_user.user_financier

    if @mandate.check_iban && (IBANTools::IBAN.new(@current_user.user_financier.user_financier_rib.iban).code != IBANTools::IBAN.new(@mandate.iban).code)
      @error = false
    else
      @error = true
    end
  end

  def confirm_mandate
    @mandate = UserFinancierMandate.new(params_mandate)
    @mandate.adresse_ip = request.remote_ip
    @mandate.rum = UserFinancierMandate.generate_reference
    @mandate.user_financier_id = @current_user.user_financier.id
    @mandate.email = @current_user.email
    if @mandate.save
      @error = false
    else
      @error = true
    end
  end

  def download_mandate
    @mandate = UserFinancierMandate.find_by_rum(params[:rum])
    @user_financier = @mandate.user_financier

    if !@user_financier.centre.ics.blank?
      @creancier = @user_financier.centre
    elsif !@user_financier.centre.school_program.ics.blank?
      @creancier = @user_financier.centre.school_program
    end

    pdf = render_to_string pdf: "mandat_sepa", template: "admin/manage/user_financier_mandates/mandat_sepa_pdf.html.erb", margin: { top: 20 }
    file_name = "MANDAT_SEPA_#{@mandate.rum}.pdf"
    send_data pdf, :filename => file_name, :type => "application/pdf", :disposition => "attachment"
  end

  private

  def params_mandate
    params.require(:user_financier_mandate).permit!
  end

  def params_rib
    params.require(:user_financier_rib).permit!
  end

  def params_payer_authorisation
    params.require(:user_financier_rib).permit!
  end
end
