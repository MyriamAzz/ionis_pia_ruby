class Admin::Accounting::StatisticsController < AdminController
  load_and_authorize_resource class: false

  def index
    session[:stats_filter_school_year] = current_user.user_admin.current_centre.school_program.get_current_school_year.id rescue nil
    session[:stats_filter_centre] = @centres.first.id
  end

  def filter
    if params[:school_year] && params[:school_year] == "-1"
      session[:stats_filter_school_year] = nil
    elsif params[:school_year]
      session[:stats_filter_school_year] = params[:school_year]
    elsif params[:centre]
      session[:stats_filter_centre] = params[:centre]
    end
  end

  def data
    @instalments = UserFinancierSubscriptionInstalment.joins(:user_financier_subscription).where("user_financier_subscriptions.school_year_id = ?", session[:stats_filter_school_year])
    render partial: "data"
  end

  def data_students
    users = UserFinancier.where(centre_id: session[:stats_filter_centre]).includes([:user, :centre, :user_financier_subscriptions]).joins(:user_financier_subscriptions).where("user_financier_subscriptions.school_year_id = ?", session[:stats_filter_school_year])

    data = []
    users.each do |user|
      subscription = user.user_financier_subscriptions.where(school_year_id: session[:stats_filter_school_year]).includes(:user_financier_subscription_instalments).last rescue nil

      data << { :id => user.user.id, :uuid => user.user.uuid, :student => user.etu_nom_prenom, :centre => user.centre.nom, :annee_scolaire => (subscription.school_year.nom rescue nil),
                :formation => (subscription.formation_annee.formation.nom rescue nil), :souscription_type => (subscription.statut_etu.humanize rescue nil),
                :souscription_mode => (subscription.payment_mode_scolarite.humanize rescue nil), :souscription_id => (subscription.id rescue nil),
                :souscription_status => (subscription.statut_before_type_cast rescue nil),
                :relaunch => user.dont_relaunch,
                :relaunch_comment => user.dont_relaunch_comment,
                :inactive => subscription.user_financier_subscription_instalments.stat_not_invoiced.sum(:montant),
                :sales => subscription.user_financier_subscription_instalments.stat_invoiced.sum(:montant),
                :charged => subscription.user_financier_subscription_instalments.stat_collected.sum(:montant),
                :failed => subscription.user_financier_subscription_instalments.stat_expired.sum(:montant) }
    end
    render json: data
  end

  def change_relaunch
  end

  def set_relaunch
  end
end
