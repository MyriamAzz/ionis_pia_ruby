class Admin::Settings::PaymentTermsController < AdminController
  authorize_resource class: false

  def index
    @school_program = current_user.user_admin.current_centre.school_program
  end
end
