class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def portail
    if user_signed_in? && current_user.user?
      redirect_to user_dashboard_path
    elsif user_signed_in? && !current_user.user?
      redirect_to admin_dashboard_path
    end
  end
end
