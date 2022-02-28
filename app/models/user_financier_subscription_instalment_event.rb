class UserFinancierSubscriptionInstalmentEvent < ApplicationRecord
  belongs_to :user_financier_subscription_instalment

  enum gocardless_status: [:created, :customer_approval_granted, :customer_approval_denied, :submitted, :confirmed,
                           :chargeback_cancelled, :paid_out, :late_failure_settled, :chargeback_settled, :surcharge_fee_credited,
                           :failed, :charged_back, :cancelled, :resubmission_requested, :bank_account_closed]

  validates_uniqueness_of :gocardless_id, case_sensitive: true, :allow_nil => true

  # after_create :after_create_process
  after_commit :after_create_process, on: :create

  def after_create_process
    if self.user_financier_subscription_instalment.user_financier_subscription_instalment_events.last.id == self.id
      if self.paid_out?
        self.user_financier_subscription_instalment.update(statut: :done)
      elsif self.failed? or self.late_failure_settled?
        self.user_financier_subscription_instalment.update(statut: :failed)
      elsif self.charged_back? or self.chargeback_settled? or self.chargeback_settled?
        self.user_financier_subscription_instalment.update(statut: :refused)
      elsif self.confirmed?
        self.user_financier_subscription_instalment.update(statut: :done)
      elsif self.cancelled? && self.gocardless_cause == "bank_account_closed"
        self.user_financier_subscription_instalment.update(statut: :refused)
      elsif self.cancelled?
        self.user_financier_subscription_instalment.update(statut: :canceled)
      end
    end
  end

  def self.LogEventGoCardless(event)
    instalment = UserFinancierSubscriptionInstalment.find_by_gocardless_id(event.links.payment) rescue nil
    if instalment
      e = self.new(user_financier_subscription_instalment_id: instalment.id, gocardless_id: event.id,
                   gocardless_status: event.action, gocardless_cause: event.details["cause"],
                   gocardless_description: event.details["description"], gocardless_date: event.created_at.to_datetime.strftime("%Y-%m-%d %H:%M:%S.%3N"))
      e.save
      return true
    else
      return false
    end
  end
end
