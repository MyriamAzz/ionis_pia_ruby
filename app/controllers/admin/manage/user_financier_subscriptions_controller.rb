class Admin::Manage::UserFinancierSubscriptionsController < AdminController
  load_and_authorize_resource param_method: :params_user_financier_subscription

  def show
    @user_financier_subscription = UserFinancierSubscription.find(params[:id])
  end

  def preview
  end

  def new
    @student = User.find_by_uuid(params[:student_id])
    @user_financier_subscription = UserFinancierSubscription.new

    @school_years = current_user.user_admin.current_centre.school_program.school_years
    @formations = Formation.where(centre_id: @student.user_financier.centre_id)
  end

  def create
    if FormationAnnee.where(formation_id: params[:formation_id], school_year_id: params[:base_school_year_id]).first
      subscription = UserFinancierSubscription.new(params_user_financier_subscription)
      @student = User.find_by_uuid(params[:student_id])
      subscription.formation_annee_id = FormationAnnee.where(formation_id: params[:formation_id], school_year_id: params[:base_school_year_id]).first.id
      subscription.user_financier_id = @student.user_financier.id
      if subscription.save
        UserFinancierTimeline.create_subscription(subscription, current_user.id)
      else
        @error = true
      end
    else
      @error = true
    end
  end

  def edit_modalite
  end

  def preview_update_modalite
    @modalite = params[:modalite].to_i
    @montant = @user_financier_subscription.formation_annee.read_attribute("modalite_#{@modalite}")
    @reste = ((@montant - @user_financier_subscription.amount_paid_scolarite - @user_financier_subscription.reduction) / @modalite).round
    @remise = @user_financier_subscription.remaining_discount_to_deduct
  end

  def update_modalite
    if params[:echeances]
      @user_financier_subscription.modalite_change(params[:modalite].to_i, params[:echeances])
      @student = User.find_by_uuid(params[:student_id])
      UserFinancierTimeline.modalite_change_subscription(@user_financier_subscription, current_user.id)
    else
      @error = true
    end
  end

  def launch_change_formation
    @school_years = current_user.user_admin.current_centre.school_program.school_years
    @student = User.find(params[:student_id])
    @formations = Formation.where(centre_id: @student.user_financier.centre_id)
  end

  def simulate_change_formation
    @formation_annee = FormationAnnee.where(formation_id: params[:formation_id], school_year_id: params[:base_school_year_id]).first rescue nil
    if !@formation_annee.nil? && !@formation_annee.read_attribute("modalite_#{@user_financier_subscription.modalite}").blank?
      @montant = @formation_annee.read_attribute("modalite_#{@user_financier_subscription.modalite}") / @user_financier_subscription.modalite
      @remise = @user_financier_subscription.reduction
      if @remise > 0 && @user_financier_subscription.reduction_type_all?
        @remise = (@remise / @user_financier_subscription.modalite).round
      end
    else
      @error = true
    end
  end

  def apply_change_formation
    if @user_financier_subscription.apply_change_formation(params[:formation_annee], params[:echeances])
      @student = User.find(params[:student_id])
      UserFinancierTimeline.formation_change_subscription(@user_financier_subscription, current_user.id)
    else
      @error = true
    end
  end

  def launch_change_statut
  end

  def apply_change_statut
    if params[:user_financier_subscription][:statut_etu] != @user_financier_subscription.statut_etu
      @user_financier_subscription.apply_change_statut(params[:instalments], params[:user_financier_subscription][:statut_etu])
      UserFinancierTimeline.change_statut_etu_subscription(@user_financier_subscription, current_user.id)
      @student = User.find(params[:student_id])

      # else
      #   @error = true
      # end
    else
      @error = true
    end
  end

  def launch_closure
  end

  def apply_closure
    @student = User.find(params[:student_id])

    if params[:instalments] && params[:type]
      @user_financier_subscription.apply_closure(params[:instalments], params[:type])
      UserFinancierTimeline.closure_subscription(@user_financier_subscription, current_user.id)
    elsif @user_financier_subscription.waiting_user? or @user_financier_subscription.apprentissage? or @user_financier_subscription.contrat_pro? or @user_financier_subscription.etudiant?
      @user_financier_subscription.apply_closure(nil, params[:type])
      UserFinancierTimeline.closure_subscription(@user_financier_subscription, current_user.id)
    else
      @error = true
    end
  end

  def cancel_closure
    @user_financier_subscription.cancel_closure
    @student = User.find(params[:student_id])
    UserFinancierTimeline.cancel_closure_subscription(@user_financier_subscription, current_user.id)
  end

  def launch_discount
    @already = @user_financier_subscription.amount_paid_closure
    @reste = @user_financier_subscription.remaining_amount_to_pay_scolarite
  end

  def simulate_discount
    if params[:discount_euros].blank? && params[:discount_percent].blank?
      @error = "empty"
    else
      if !params[:discount_euros].blank?
        @discount = params[:discount_euros].to_i
      elsif !params[:discount_percent].blank?
        montant = @user_financier_subscription.formation_annee.read_attribute("modalite_#{@user_financier_subscription.modalite}")
        @discount = (montant * (params[:discount_percent].to_i / 100.0)).round
      end
      if params[:mode] == "1"
        @instalments = @user_financier_subscription.remaining_instalments_scolarite
        @discount = (@discount / @instalments.count)
        @mode = true
      else
        @mode = false
      end
    end
  end

  def apply_discount
    @user_financier_subscription.apply_discount(params[:mode], params[:discount])
    @student = User.find(params[:student_id])
    UserFinancierTimeline.discount_subscription(@user_financier_subscription, current_user.id)
  end

  def validate
    subscription = UserFinancierSubscription.find(params[:user_financier_subscription_id])
    if subscription.update(statut: :waiting_compta)
      @user = User.find(params[:user_id])
    else
      @error = true
    end
  end

  def edit
    @user_financier_subscription = UserFinancierSubscription.find(params[:id])
    @school_years = SchoolYear.active
    @formations = Formation.where(centre_id: @user_financier_subscription.user_financier.centre_id)
  end

  def edit_instalments
    @school_fees = @user_financier_subscription.formation_annee.read_attribute("modalite_#{@user_financier_subscription.modalite}")
    @amount = @user_financier_subscription.user_financier_subscription_instalments.stat_turnover.sum(:montant)
  end

  def update
    if @user_financier_subscription.update(params_user_financier_subscription)
      @student = User.find(params[:student_id])
    else
      @error = true
    end
  end

  def update_instalments
    @user_financier_subscription.assign_attributes(params_user_financier_subscription)
    @user_financier_subscription.assign_attributes(updated_by: current_user)
    if @user_financier_subscription.save
      @student = User.find_by_uuid(params[:student_id])
      @school_fees = @user_financier_subscription.formation_annee.read_attribute("modalite_#{@user_financier_subscription.modalite}")
      @amount = @user_financier_subscription.user_financier_subscription_instalments.where(v_type: :frais_scolarite).sum(:montant)
      if (@amount > @school_fees) && !current_user.compta? && !current_user.super_admin?
        @user_financier_subscription.accounting_alerts.create(centre_id: @user_financier_subscription.formation_annee.formation.centre_id, user_id: current_user.id, atype: :alert_payment)
      end
      UserFinancierTimeline.echeances_change_subscription(@user_financier_subscription, current_user.id)
    else
      @error = true
    end
  end

  def init_credit
    @user_financier_subscription = UserFinancierSubscription.find(params[:user_financier_subscription_id])
  end

  def create_credit
    @user_financier_subscription = UserFinancierSubscription.find(params[:user_financier_subscription_id])
    @error = true
  end

  def destroy
    subscription = UserFinancierSubscription.find(params[:id])
    @student = User.find(params[:student_id])
    if subscription.can_cancel
      if subscription.destroy
        # @user = User.find(params[:user_id])
        UserFinancierTimeline.cancel_subscription(subscription, current_user.id)
      else
        @error = true
      end
    else
      @error = true
    end
  end

  def facture_proforma_pdf
    @data = @user_financier_subscription
    pdf = render_to_string pdf: "facture", template: "admin/manage/user_financier_subscriptions/facture_proforma_pdf.html.erb", margin: { top: 20 }
    file_name = "facture_proforma.pdf"
    send_data pdf, filename: file_name, :type => "application/pdf", :disposition => "attachment"
  end

  def facture_pdf
    @data = @user_financier_subscription
    pdf = render_to_string pdf: "facture", template: "admin/manage/user_financier_subscriptions/facture_pdf.html.erb", margin: { top: 20 }
    file_name = "facture.pdf"
    send_data pdf, filename: file_name, :type => "application/pdf", :disposition => "attachment"
  end

  def attestation_scolarite
    @data = @user_financier_subscription
    @program = @user_financier_subscription.user_financier.centre.school_program
    pdf = render_to_string pdf: "attestation_scolarite", template: "admin/manage/user_financier_subscriptions/attestation_scolarite_pdf.html.erb", margin: { top: 20 }
    file_name = "attestation_scolarite.pdf"
    send_data pdf, filename: file_name, :type => "application/pdf", :disposition => "attachment"
  end

  private

  def params_user_financier_subscription
    params.require(:user_financier_subscription).permit!
  end
end
