class GoCardlessDailyWorker
  include Sidekiq::Worker

  def perform(*args)
    UserFinancierSubscriptionInstalment.GoCardlessDaily
  end
end
