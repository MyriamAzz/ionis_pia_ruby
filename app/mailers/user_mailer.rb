#encoding: utf-8
class UserMailer < ApplicationMailer
  # default :from => "E-ARTSUP - Plateforme Inscription Administrative <informatique@e-artsup.net>"
  default template_path: "user/mailers"

  def send_credentials(user, password)
    @user = user
    @password = password
    mail(:from => @user.get_email_from, :to => @user.email, :subject => "Vos identifiants de connexion", :content_type => "text/html")
  end

  def instalment_paid_gc(instalment)
    @user = instalment.user_financier_subscription.user_financier.user
    @instalment = instalment
    mail(:from => @user.get_email_from, :to => @user.email, :subject => "Prélèvement payé", :content_type => "text/html")
  end

  def instalment_failed_gc(instalment)
    @user = instalment.user_financier_subscription.user_financier.user
    @instalment = instalment
    mail(:from => @user.get_email_from, :to => @user.email, :subject => "Prélèvement echoué", :content_type => "text/html")
  end

  def instalment_rejected_gc(instalment)
    @user = instalment.user_financier_subscription.user_financier.user
    @instalment = instalment
    mail(:from => @user.get_email_from, :to => @user.email, :subject => "Prélèvement refusé", :content_type => "text/html")
  end

  def reinscription_to_student_cycle_1(subscription)
    @subscription = subscription
    @user = subscription.user_financier.user
    mail(:from => @user.get_email_from, :to => @user.user_financier.etu_email, :subject => "Réinscription #{subscription.school_year.nom} – 1er cycle - Modalités de paiement", :content_type => "text/html")
  end

  def reinscription_to_student_cycle_2(subscription)
    @subscription = subscription
    @user = subscription.user_financier.user
    mail(:from => @user.get_email_from, :to => @user.user_financier.etu_email, :subject => "Réinscription #{subscription.school_year.nom} – 2nd cycle - Modalités de paiement", :content_type => "text/html")
  end

  def reinscription_to_rf(subscription)
    @subscription = subscription
    @user = subscription.user_financier.user
    mail(:from => @user.get_email_from, :to => @user.email, :subject => "Réinscription #{subscription.school_year.nom} – Information répondant financier", :content_type => "text/html")
  end

  def reinscription_confirm_to_rf(subscription, password)
    @subscription = subscription
    @password = password
    @user = subscription.user_financier.user
    mail(:from => @user.get_email_from, :to => @user.email, :subject => "Réinscription #{subscription.school_year.nom} – Confirmation", :content_type => "text/html")
  end
end
