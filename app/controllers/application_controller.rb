class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden, content_type: "text/html" }
      format.html { redirect_to main_app.root_url, notice: exception.message }
      format.js { head :forbidden, content_type: "text/html" }
    end
  end

  def after_sign_in_path_for(resource)
    if current_user.admin? || current_user.super_admin? || current_user.compta? || current_user.supervisor?
      admin_dashboard_path()
    elsif current_user.user?
      user_dashboard_path()
    end
  end
end
