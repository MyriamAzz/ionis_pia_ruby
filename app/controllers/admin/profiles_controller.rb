class Admin::ProfilesController < AdminController
  authorize_resource :class => false

  def switch_centre
    centre = Centre.find(params[:centre_id]) rescue nil
    if centre && current_user.centres.include?(centre)
      current_user.user_admin.update(centre_id: centre.id)
    else
    end
    redirect_to request.env["HTTP_REFERER"]
  end

  def switch_school_program
    school_program = SchoolProgram.find(params[:school_program_id]) rescue nil
    if school_program && current_user.school_programs.include?(school_program)
      current_user.user_admin.update(centre_id: current_user.centres.where(school_program_id: school_program.id).first.id)
    else
    end
    redirect_to request.env["HTTP_REFERER"]
  end
end
