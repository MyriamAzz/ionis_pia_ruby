class AdminMailer < ApplicationMailer
  default :from => DEFAULT_EMAIL_FROM
  default template_path: "admin/mailers"

  def send_credentials(user, password)
    @user = user
    @password = password
    mail(:to => @user.email, :subject => "Identifiants de connexion", :content_type => "text/html")
  end
end
