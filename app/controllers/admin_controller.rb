class AdminController < ApplicationController
  before_action :require_admin
  before_action :set_admin

  def require_admin
    unless current_user.admin? || current_user.super_admin? || current_user.compta? || current_user.supervisor?
      redirect_to root_path
    end
  end

  def set_admin
    @centres = current_user.centres
    if @centres.any?
      if !current_user.user_admin.current_centre
        current_user.user_admin.update(centre_id: @centres.first.id)
        # session[:centre_id] = @segments.first.id
        # session[:segment_name] = @segments.first.name
        # session[:company_id] = @segments.first.company.id
        # session[:company_name] = @segments.first.company.name
        # @segments = current_user.segments.where(company: @segments.first.company)
        # @companies = current_user.segment_companies
      else
        if !current_user.centres.include?(current_user.user_admin.current_centre)
          current_user.user_admin.update(centre_id: @centres.first.id)
        end
        # session[:segment_id] = current_user.current_centre.id
        # session[:segment_name] = current_user.current_centre.name
        # session[:company_id] = current_user.current_centre.company.id
        # session[:company_name] = current_user.current_centre.company.name
        # @segments = current_user.segments.where(company_id: current_user.current_centre.company)
        # @companies = current_user.segment_companies
      end
      @centres = current_user.centres.where(school_program_id: session[:school_program_id])
      session[:school_program_id] = current_user.user_admin.current_centre.school_program_id
      session[:centre_id] = current_user.user_admin.current_centre.id

      #   @current_centre = current_user.current_centre
      #   @current_company = current_user.current_centre.company
    else
      sign_out current_user
      flash[:alert] = "Aucune affectation pour ce compte. Veuillez contacter le service technique."
      redirect_to new_user_session_path()
    end
  end
end
