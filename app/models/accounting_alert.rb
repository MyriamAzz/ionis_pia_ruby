class AccountingAlert < ApplicationRecord
  belongs_to :centre, required: false
  belongs_to :user, required: false
  belongs_to :user_financier_subscription
  belongs_to :handled_by, class_name: "User", required: false

  enum atype: { alert_discount: 0, alert_demission: 1, alert_payment: 2, alert_other: 3, alert_late_registration: 4, alert_exclusion: 5, alert_change_payment_modality: 6 }
  enum status: { waiting: 0, done: 1, refused: 2 }, _default: :waiting

  after_create :process_after_create

  def process_after_create
    self.update(centre_id: self.user_financier_subscription.user_financier.centre_id)
  end
end
