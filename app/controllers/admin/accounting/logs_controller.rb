class Admin::Accounting::LogsController < AdminController
  load_and_authorize_resource class: false

  before_action :get_logs, only: [:table_json_logs, :export_unprocessed, :export_all]
  before_action :get_user_financiers, only: [:export_codes_tiers, :export_ibans, :export_rf_without_mandate]

  def index
    session[:logs_filter_school_year] = current_user.user_admin.current_centre.school_program.get_current_school_year.id rescue nil
  end

  def filter
    if params[:school_year] && params[:school_year] == "-1"
      session[:logs_filter_school_year] = nil
    elsif params[:school_year]
      session[:logs_filter_school_year] = params[:school_year]
    end
  end

  def table_json_logs
    @data = []
    @logs.each do |log|
      compose_json(log)
    end
    render json: @data
  end

  def export_unprocessed
    logs = @logs.where(exported: false)
    @csv_file = logs.to_csv_async
    logs.update_all(exported: true, exported_at: DateTime.now, exported_by: current_user.id)
  end

  def export_all
    # logs = LogSale.all
    @csv_file = @logs.to_csv_async
    # logs.update_all(exported: true)
  end

  def export_selected
    logs = LogSale.where(id: params["records"])
    @csv_file = logs.to_csv_async
  end

  def export_codes_tiers
    filename = "TIERS_#{current_user.user_admin.current_centre.school_program.school.nom}_#{DateTime.now.strftime("%d%m%Y")}"
    respond_to do |format|
      format.html
      format.csv { send_data "\uFEFF" + @users.to_csv_codes_tiers, filename: "#{filename}.csv" }
    end
  end

  def export_ibans
    filename = "BANK_#{current_user.user_admin.current_centre.school_program.school.nom}_#{DateTime.now.strftime("%d%m%Y")}"
    respond_to do |format|
      format.html
      format.csv { send_data "\uFEFF" + @users.to_csv_ibans, filename: "#{filename}.csv" }
    end
  end

  def export_rf_without_mandate
    filename = "RF_SANS_MANDAT_" + DateTime.now.strftime("%d%m%y")
    respond_to do |format|
      format.html
      format.csv { send_data "\uFEFF" + @users.to_csv_without_mandate, filename: "#{filename}.csv" }
    end
  end

  private

  def get_logs
    @logs = LogSale.includes(user_financier_subscription: [:user_financier]).joins(user_financier_subscription: [:user_financier]).where("user_financier_subscriptions.school_year_id = ?", session[:logs_filter_school_year]).where("user_financiers.centre_id IN (?)", @centres.pluck(:id))
  end

  def get_user_financiers
    @users = UserFinancier.where(centre_id: @centres).includes([:user, :centre, :user_financier_subscriptions])
  end

  def compose_json(log)
    echeance = log.date_echeance.strftime("%d/%m/%Y") rescue ""
    @data << { :id => log.id, :code_journal => log.code_journal, :numero_facture => log.numero_facture, :libelle => log.libelle, :nom_complet => log.nom_complet,
               :debit => log.debit, :credit => log.credit, :type_ecriture => log.type_ecriture, :date_echeance => echeance, :date_import => log.date_import.strftime("%d/%m/%Y"), :created_at => log.created_at.strftime("%d/%m/%Y"),
               :exported => log.exported, :modalite => log.modalite, :type_frais => log.type_frais, :annee => log.annee, :mode_reglement => log.mode_reglement, :analytique => log.analytique,
               :compte_tiers => log.compte_tiers, :compte_general => log.compte_general, :reference => log.reference }
  end
end
