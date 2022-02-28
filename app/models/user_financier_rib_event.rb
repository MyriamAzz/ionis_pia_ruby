class UserFinancierRibEvent < ApplicationRecord
  belongs_to :user_financier
  enum gocardless_status: [:created, :customer_approval_granted, :customer_approval_skipped, :active, :cancelled,
                           :failed, :transferred, :expired, :submitted, :resubmission_requested,
                           :reinstated, :replaced]
  validates_uniqueness_of :gocardless_id, case_sensitive: true, :allow_nil => true

  def self.LogEventGoCardless(event)
    rib = UserFinancierRib.find_by_gocardless_mandate_id(event.links.mandate) rescue nil
    if rib
      user = rib.user_financier
      if event.details["reason_code"]
        reason = event.details["reason_code"]
      else
        reason = ""
      end
      e = self.new(user_financier_id: user.id, gocardless_id: event.id, gocardless_mandate_id: event.links.mandate,
                   gocardless_status: event.action, gocardless_cause: event.details["cause"],
                   gocardless_reason_code: reason, gocardless_description: event.details["description"])
      e.save
      return true
    else
      return false
    end
  end
end
