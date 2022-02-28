class Admin::DashboardController < AdminController
  authorize_resource :class => false

  before_action :get_subscriptions, only: [:show, :async_stats, :async_stats_1, :async_stats_2, :chart_registrations, :chart_new_registrations]

  def show
    session[:dashboard_filter_school_year] = current_user.user_admin.current_centre.school_program.get_current_school_year.id rescue nil
  end

  def filter
    if params[:school_year] && params[:school_year] == "-1"
      session[:dashboard_filter_school_year] = nil
    elsif params[:school_year]
      session[:dashboard_filter_school_year] = params[:school_year]
    end
  end

  def async_stats
    @students = @rows
    render partial: "async_stats"
  end

  def async_stats_1
    @students = @rows
    @formations = Formation.where(centre_id: @centres.pluck(:id))
    @alerts = AccountingAlert.where(centre_id: @centres.pluck(:id)).includes(:user, :user_financier_subscription).where(user_financier_subscription: { school_year_id: session[:dashboard_filter_school_year] }).order(created_at: :desc).limit(5)
    render partial: "async_stats_1"
  end

  def chart_registrations
    @data = @rows.where(s_type: [:reinscription]).group_by_day(:created_at).distinct.count
    render json: @data
  end

  def chart_new_registrations
    @data = @rows.where(s_type: [:inscription]).group_by_day(:created_at).distinct.count
    render json: @data
  end

  private

  def get_subscriptions
    if session[:dashboard_filter_school_year].nil?
      @rows = UserFinancierSubscription.includes([:user_financier]).where(user_financier: { centre_id: @centres })
    else
      @rows = UserFinancierSubscription.includes([:user_financier]).where(school_year_id: session[:dashboard_filter_school_year], user_financier: { centre_id: @centres })
    end
  end
end
