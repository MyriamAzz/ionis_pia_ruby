class GoCardlessSyncPayoutsWorker
  include Sidekiq::Worker

  def perform(*args)
    Payout.sync_gc_payouts
  end
end
