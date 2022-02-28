#encoding: utf-8

class AuthsMailer < Devise::Mailer
  # default :from => "E-ARTSUP - Plateforme Inscription Administrative <informatique@e-artsup.net>"
  default template_path: "auths/mailer"
  # send password reset instructions
  def reset_password_instructions(user, token, opts = {})
    @user = user
    @token = token
    mail(:from => @user.get_email_from, :to => @user.email, :subject => "Réinitialiser mon mot de passe", :content_type => "text/html")
  end

  def email_forgot(user)
    @user = user
    mail(:from => @user.get_email_from, :to => user.email, :subject => "Votre login de connexion", :content_type => "text/html")
  end
end
