class Admin::Manage::StudentsController < AdminController
  load_and_authorize_resource param_method: :params_user, class: "User", find_by: :uuid

  require "csv"

  def index
    session[:students_filter_school_year] = current_user.user_admin.current_centre.school_program.get_current_school_year.id rescue nil
    # @centres = current_user.admin_get_centres
    # if @centres.count > 1
    #   session[:admin_multi_centre] = true
    # else
    #   session[:admin_multi_centre] = false
    # end
  end

  def filter
    if params[:school_year] && params[:school_year] == "-1"
      session[:students_filter_school_year] = nil
    elsif params[:school_year]
      session[:students_filter_school_year] = params[:school_year]
    end
  end

  def new
    @user = User.new
    @user.build_user_financier
  end

  def create
    @user = User.new(params_user)
    @user.role = :user
    @user.skip_password_validation = true
    if @user.save
      @error = false
    else
      @error = true
    end
  end

  def edit
    # @user = User.includes(:user_financier).find_by_uuid(params[:id])
    session[:admin_manage_edit_user_navbar] = 3
  end

  def edit_card
    session[:admin_manage_edit_user_navbar] = params[:card].to_i
  end

  def update
    if @student.update(params_user)
    else
      @error = true
    end
  end

  def follow
    UserFinancierTimeline.tag_follow(@student.user_financier.id, current_user.id, !@student.user_financier.follow)
    @student.user_financier.update(follow: !@student.user_financier.follow)
  end

  def change_relaunch
    if params[:value] == "true"
      @comment = true
    else
      @student.user_financier.update(dont_relaunch: false)
      @comment = false
    end
  end

  def dont_relaunch
    @student.user_financier.update(dont_relaunch: true, dont_relaunch_comment: params[:descr])
    @student.user_financier.user_financier_timelines.create(user: current_user, comment: true, descr: params[:descr], priority: 0)
  end

  def transfer
    if params["user"]["user_financier_attributes"]["centre_id"].to_i != @student.user_financier.centre_id && @student.user_financier.transfer(params["user"]["user_financier_attributes"]["centre_id"])
      session[:admin_manage_edit_user_navbar] = 3
      @error = false
    else
      @error = true
    end
  end

  def destroy
    @student.destroy
    redirect_to admin_manage_users_path
  end

  def send_email_ids
    password = Devise.friendly_token.first(10)
    @student.password = password
    if @student.save
      UserMailer.send_credentials(@student, password).deliver_later
    else
      @error = true
    end
  end

  def export
    # users = UserFinancier.all
    users = UserFinancier.where(centre_id: @centres).includes([:user, :centre, :user_financier_subscriptions])
    filename = "EXPORT_" + DateTime.now.strftime("%d-%m-%Y") + "_#{current_user.user_admin.current_centre.school_program.school.nom}"
    respond_to do |format|
      format.html
      format.csv { send_data "\uFEFF" + users.to_csv_export, filename: "#{filename}.csv" }
    end
  end

  def export_reinscription
    users = UserFinancier.where(centre_id: @centres).includes([:user, :centre, :user_financier_subscriptions])
    filename = "EXPORT_REINSCRIPTION_" + DateTime.now.strftime("%d%m%y") + "_#{current_user.user_admin.current_centre.school_program.school.nom}"
    respond_to do |format|
      format.html
      format.csv { send_data "\uFEFF" + users.to_csv_export_reinscription, filename: "#{filename}.csv" }
    end
  end

  def init_import
  end

  def import
    @errors = []
    @count = 0
    if params[:type]
      CSV.foreach(params[:file].path, headers: true, col_sep: ";", encoding: "iso-8859-1:utf-8") do |row|
        @count += 1
        centre = @centres.find_by_ville(row[16]) rescue nil
        if centre.nil?
          @errors << [row[0], row[1], "ERREUR CAMPUS"]
          next
        end
        if !Formation.where(code: row[17], centre_id: centre.id).any?
          @errors << [row[0], row[1], "ERREUR FORMATION"]
          next
        end

        password = Devise.friendly_token.first(10)
        user_financier = UserFinancier.find_by(etu_email: row[2]) rescue nil

        if user_financier
          already_exist = true
          user = user_financier.user
        else
          already_exist = false
          if row[7].blank?
            user = User.new(email: row[2], role: :user, password: password)
          else
            user = User.new(email: row[9], role: :user, password: password)
          end
        end

        if row[7].blank?
          user.build_user_financier if user.user_financier.nil?
          user.user_financier.centre = centre
          user.user_financier.code_tiers = row[15]
          user.user_financier.nom = row[0]
          user.user_financier.prenom = row[1]
          user.user_financier.adresse = row[3]
          user.user_financier.ville = row[5]
          user.user_financier.code_postal = row[4]
          user.user_financier.pays = nil
          user.user_financier.tel = row[6]
          user.user_financier.etu_nom = row[0]
          user.user_financier.etu_prenom = row[1]
          user.user_financier.etu_email = row[2]
          user.user_financier.etu_tel = row[6]
          user.user_financier.etu_adresse = row[3]
          user.user_financier.etu_ville = row[5]
          user.user_financier.etu_code_postal = row[4]
          user.user_financier.etu_pays = nil
        else
          user.build_user_financier if user.user_financier.nil?
          user.user_financier.centre = centre
          user.user_financier.code_tiers = row[15]
          user.user_financier.nom = row[7]
          user.user_financier.prenom = row[8]
          user.user_financier.adresse = row[10]
          user.user_financier.ville = row[12]
          user.user_financier.code_postal = row[11]
          user.user_financier.pays = row[13]
          user.user_financier.tel = row[14]
          user.user_financier.etu_nom = row[0]
          user.user_financier.etu_prenom = row[1]
          user.user_financier.etu_email = row[2]
          user.user_financier.etu_tel = row[6]
          user.user_financier.etu_adresse = row[3]
          user.user_financier.etu_ville = row[5]
          user.user_financier.etu_code_postal = row[4]
          user.user_financier.etu_pays = nil
        end

        if user.user_financier.user_financier_subscriptions.joins(:school_year).where(school_years: { nom: row[19] }).any?
          @errors << [row[0], row[1], "SOUSCRIPTION DÉJÀ EXISTANTE POUR L'ANNÉE SCOLAIRE"]
          next
        end

        if !already_exist
          user.user_financier.imported = true
        end

        if user.save
          if params[:type] == "reinscription" && user.user_financier.import_create_subscription(centre, params[:type], row[17], row[18], row[19], row[20], row[21], true, !already_exist)
          elsif params[:type] == "inscription" && user.user_financier.import_create_subscription(centre, params[:type], row[17], row[18], row[19], row[20], row[21], false, !already_exist)
          else
            if !already_exist
              user.destroy
            end
            @errors << [row[0], row[1], "ERREUR CREATION SOUSCRIPTION"]
            next
          end
        else
          @errors << [row[0], row[1], user.errors.full_messages]
          next
        end
      end
    end
  end

  def table_json
    if session[:students_filter_school_year].nil?
      users = UserFinancier.where(centre_id: @centres).includes([:user, :centre, :user_financier_subscriptions])
    else
      users = UserFinancier.where(centre_id: @centres).includes([:user, :centre, :user_financier_subscriptions]).joins(:user_financier_subscriptions).where("user_financier_subscriptions.school_year_id = ?", session[:students_filter_school_year])
    end
    data = []
    users.each do |user|
      if session[:students_filter_school_year].nil?
        subscription = user.user_financier_subscriptions.last rescue nil
      else
        subscription = user.user_financier_subscriptions.where(school_year_id: session[:students_filter_school_year]).last rescue nil
      end
      data << { :id => user.user.id, :uuid => user.user.uuid, :etu_nom => user.etu_nom, :etu_prenom => user.etu_prenom, :etu_email => user.etu_email,
                :nom => user.nom, :prenom => user.prenom, :centre => user.centre.nom, :annee_scolaire => (subscription.school_year.nom rescue nil),
                :formation => (subscription.formation_annee.formation.nom rescue nil), :souscription_type => (subscription.statut_etu.humanize rescue nil),
                :souscription_status => (subscription.statut_before_type_cast rescue nil) }
    end
    render json: data
  end
end

private

def params_user
  params.require(:user).permit!
end
