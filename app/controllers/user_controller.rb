class UserController < ApplicationController
    before_action :require_user
    def require_user
        unless current_user.user?
          redirect_to root_path
        end
    end
end
