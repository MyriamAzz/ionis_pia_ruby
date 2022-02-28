#encoding: utf-8
class Admin::Accounting::PaymentsController < AdminController
  load_and_authorize_resource class: false

  before_action :get_instalments, only: [:widgets, :table_json, :export, :export_expired, :export_all_expired, :export_done_failed_all, :export_all, :import_reconciliation]

  def index
    session[:payments_filter_school_year] = current_user.user_admin.current_centre.school_program.get_current_school_year.id rescue nil
  end

  def filter
    if params[:school_year] && params[:school_year] == "-1"
      session[:payments_filter_school_year] = nil
    elsif params[:school_year]
      session[:payments_filter_school_year] = params[:school_year]
    end
  end

  def widgets
    render partial: "widgets"
  end

  def export
    filename = "ECHEANCES_" + DateTime.now.strftime("%d%m%y")
    respond_to do |format|
      format.html
      format.csv { send_data "\uFEFF" + @instalments.csv_export_done_failed(true, false), filename: "#{filename}.csv" }
    end
  end

  def export_expired
    filename = "ECHEANCES_EXPIREES_" + DateTime.now.strftime("%d%m%y")
    respond_to do |format|
      format.html
      format.csv { send_data "\uFEFF" + @instalments.csv_export_expired, filename: "#{filename}.csv" }
    end
  end

  def export_all_expired
    filename = "ECHEANCES_EXPIREES_" + DateTime.now.strftime("%d%m%y")
    respond_to do |format|
      format.html
      format.csv { send_data "\uFEFF" + @instalments.csv_export_expired(true), filename: "#{filename}.csv" }
    end
  end

  def export_done_failed_all
    filename = "ECHEANCES_" + DateTime.now.strftime("%d%m%y")
    respond_to do |format|
      format.html
      format.csv { send_data "\uFEFF" + @instalments.csv_export_done_failed(false, true), filename: "#{filename}.csv" }
    end
  end

  def export_all
    filename = "ECHEANCES_" + DateTime.now.strftime("%d%m%y")
    respond_to do |format|
      format.html
      format.csv { send_data "\uFEFF" + @instalments.csv_export_all, filename: "#{filename}.csv" }
    end
  end

  def init_import_reconciliation
  end

  def import_reconciliation
    @errors = []
    @count = 0
    CSV.foreach(params[:file].path, headers: true, col_sep: ";", encoding: "iso-8859-1:utf-8") do |row|
      @count += 1
      instalment = @instalments.find_by_facture(row[2].to_i.to_s) rescue nil
      if !instalment
        @errors << [row[1], row[2], "Échéance non trouvée"]
        next
      else
        instalment.update(echeance: row[4].to_date, statut: :done)
      end
    end
  end

  def export_ca
    school_year = SchoolYear.find(session[:payments_filter_school_year])
    subscriptions = UserFinancierSubscription.where(school_year_id: session[:payments_filter_school_year]).includes([:user_financier, :formation_annee, :school_year]).joins(:user_financier).where("user_financiers.centre_id IN (?)", @centres.pluck(:id))
    filename = "EXPORT_CA_" + school_year.nom.parameterize() + "_" + DateTime.now.strftime("%d%m%y")
    respond_to do |format|
      format.html
      format.csv { send_data "\uFEFF" + subscriptions.csv_export_ca, filename: "#{filename}.csv" }
    end
  end

  def export_alert_frais_scolarite
    school_year = SchoolYear.find(session[:payments_filter_school_year])
    subscriptions = UserFinancierSubscription.where(school_year_id: session[:payments_filter_school_year]).includes([:user_financier, :formation_annee, :school_year]).joins(:user_financier).where("user_financiers.centre_id IN (?)", @centres.pluck(:id))
    filename = "EXPORT_ALERTES_FRAIS_SCO_" + school_year.nom.parameterize() + "_" + DateTime.now.strftime("%d%m%y")
    respond_to do |format|
      format.html
      format.csv { send_data "\uFEFF" + subscriptions.csv_export_alert_frais_scolarite, filename: "#{filename}.csv" }
    end
  end

  def table_json
    data = []
    @instalments.each do |instalment|
      data << { :id => instalment.id, :user_id => instalment.user_financier_subscription.user_financier.user.uuid, :sub_id => instalment.user_financier_subscription_id,
                :facture => instalment.facture, :libelle => instalment.v_type.humanize, :nom_complet_etu => instalment.user_financier_subscription.user_financier.etu_nom_prenom,
                :echeance => instalment.echeance.strftime("%d/%m/%Y"), :montant => instalment.montant, :status => instalment.statut_humanized,
                :updated_at => instalment.updated_at.strftime("%d/%m/%Y"), :centre => instalment.user_financier_subscription.user_financier.centre.nom }
    end

    render json: data
  end

  private

  def get_instalments
    @instalments = UserFinancierSubscriptionInstalment.includes(user_financier_subscription: [:user_financier]).joins(user_financier_subscription: [:user_financier]).where("user_financier_subscriptions.school_year_id = ?", session[:payments_filter_school_year]).where("user_financiers.centre_id IN (?)", @centres.pluck(:id)).where(refunded: false, rescheduled: false)
  end
end
