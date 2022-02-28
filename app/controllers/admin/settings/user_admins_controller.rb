class Admin::Settings::UserAdminsController < AdminController
  load_and_authorize_resource param_method: :params_user

  def index
    session[:user_admins_archived] = false
  end

  def new
    @user_admin.build_user
  end

  def create
    user = User.amin_superadmin_compta.find_or_initialize_by(email: params_user[:user_attributes][:email])
    if user.user_admin
    else
      user.build_user_admin(nom: params_user[:nom], prenom: params_user[:prenom])
    end
    user.role = params_user[:user_attributes][:role]
    user.skip_password_validation = true
    if params[:centres] && user.save
      session[:user_admins_archived] = false
      user.user_admin_centres.where(centre_id: (current_user.user_admin.current_centre.school_program.centres.pluck(:id) - params[:centres].map(&:to_i))).destroy_all
      params[:centres].each do |centre_id|
        if current_user.user_admin.current_centre.school_program.centres.pluck(:id).include?(centre_id.to_i)
          user.user_admin_centres.create(centre_id: centre_id)
        end
      end
      if params[:school_programs]
        params[:school_programs].each do |school_program_id|
          if current_user.admin_school_programs.pluck(:id).include?(school_program_id.to_i)
            user.user_admin_school_programs.create(school_program_id: school_program_id)
          end
        end
      else
        user.user_admin_school_programs.where(school_program_id: current_user.user_admin.current_centre.school_program_id).destroy_all
      end
    else
      @error = true
    end
  end

  def edit
    if (current_user == @user_admin.user && !current_user.super_admin?) or (current_user.admin? && !@user_admin.user.admin?) or (current_user.supervisor? && !@user_admin.user.admin?)
      @error = true
    end
  end

  def update
    if params[:centres] && @user_admin.update(params_user)
      @user_admin.user.user_admin_centres.where(centre_id: (current_user.user_admin.current_centre.school_program.centres.pluck(:id) - params[:centres].map(&:to_i))).destroy_all
      params[:centres].each do |centre_id|
        if current_user.user_admin.current_centre.school_program.centres.pluck(:id).include?(centre_id.to_i)
          @user_admin.user.user_admin_centres.create(centre_id: centre_id)
        end
      end
      if params[:school_programs]
        params[:school_programs].each do |school_program_id|
          if current_user.admin_school_programs.pluck(:id).include?(school_program_id.to_i)
            @user_admin.user.user_admin_school_programs.create(school_program_id: school_program_id)
          end
        end
      else
        @user_admin.user.user_admin_school_programs.where(school_program_id: current_user.user_admin.current_centre.school_program_id).destroy_all
      end
    else
      @error = true
    end
  end

  def destroy
    if @user_admin.destroy
    else
      @error = true
    end
  end

  def filter
    if params[:archived] == "true"
      session[:user_admins_archived] = true
    else
      session[:user_admins_archived] = false
    end
  end

  def json
    users = current_user.user_admin.current_centre.school_program.users.where(archived: session[:user_admins_archived])
    var = []
    users.each do |user|
      admin = !(user.school_programs.pluck(:id) & user.admin_school_programs.pluck(:id)).empty?
      var << { :id => user.user_admin.id, :firstname => user.user_admin.prenom, :lastname => user.user_admin.nom, :email => user.email, :role => user.role, :admin => admin, :segments => user.centres.where(school_program_id: current_user.user_admin.current_centre.school_program.id).map { |a| a.nom }.to_sentence, :updated_at => user.updated_at.strftime("%d/%m/%y %H:%M") }
    end
    render json: var
  end

  private

  def params_user
    params.require(:user_admin).permit!
  end
end
