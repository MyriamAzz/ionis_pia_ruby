class Auths::EmailsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :check_school

  def new
  end

  def create
    user = UserFinancier.find_by_etu_email(params[:email])
    if user
      AuthsMailer.email_forgot(user.user).deliver_later
      redirect_to email_oublie_path(p: params[:p]), notice: "Nous avons envoyé un email avec votre identifiant à cette adresse"
    else
      redirect_to email_oublie_path(p: params[:p]), alert: "Aucun étudiant n'est referencé avec cette adresse email"
    end
  end

  protected

  def check_school
    if !params[:p]
      redirect_to root_path
    end
  end
end
