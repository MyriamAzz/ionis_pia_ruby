# frozen_string_literal: true

class Auths::PasswordsController < Devise::PasswordsController
  before_action :check_school, except: [:edit, :update]
  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  # def create
  #   super
  # end

  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name, params[:p]))
    else
      respond_with(resource)
    end
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  # def update
  #   super
  # end

  # protected

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  protected

  def check_school
    if !params[:p]
      redirect_to root_path
    end
  end

  def after_sending_reset_password_instructions_path_for(resource_name, p = nil)
    new_session_path(resource_name, p: p) if is_navigational_format?
  end
end
