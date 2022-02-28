class User::ProfilsController < UserController
  authorize_resource :class => false

  def show
  end

  def update
    if current_user.update(params_user)
    else
      @error = true
    end
  end

  def update_password
    if params[:user][:password] == params[:user][:password_confirmation]
      if params[:user][:password].length >= 8
        if current_user.update(params_user_password)
          bypass_sign_in(current_user)
        else
          @error = true
        end
      else
        @error = "limit"
      end
    else
      @error = "password"
    end
  end

  private

  def params_user_password
    params.require(:user).permit(:password, :password_confirmation)
  end

  def params_user
    params.require(:user).permit(:id, :email, user_financier_attributes: [:nom, :prenom, :tel, :adresse, :code_postal, :ville, :pays])
  end
end
