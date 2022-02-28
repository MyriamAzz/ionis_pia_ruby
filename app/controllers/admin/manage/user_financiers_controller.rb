class Admin::Manage::UserFinanciersController < AdminController
end

private

def params_user_financier
  params.require(:user_financier).permit!
end
