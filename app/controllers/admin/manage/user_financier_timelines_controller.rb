class Admin::Manage::UserFinancierTimelinesController < AdminController
  load_and_authorize_resource param_method: :params_user_financier_timeline

  def new
    @user_financier_timeline = UserFinancierTimeline.new
  end

  def create
    @user_financier_timeline = UserFinancierTimeline.new(params_user_financier_timeline)
    @student = User.find(params[:student_id])
    @user_financier_timeline.comment = true
    @user_financier_timeline.user_id = current_user.id
    @user_financier_timeline.user_financier_id = @student.user_financier.id
    @user_financier_timeline.priority = :info

    if @user_financier_timeline.save!
      session[:admin_manage_edit_user_navbar] = 2
      @error = false
    else
      @error = true
    end
  end

  private

  def params_user_financier_timeline
    params.require(:user_financier_timeline).permit!
  end
end
