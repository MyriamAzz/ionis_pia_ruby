class UserFinancierSubscriptionCredit < ApplicationRecord
  validates_uniqueness_of :user_financier_subscription_instalment_id

  belongs_to :user_financier_subscription
  belongs_to :user_financier_subscription_instalment
  belongs_to :creator, class_name: "User", foreign_key: "creator_id"

  has_many :log_sales

  after_create :process_after_create

  def self.list_code_export
    return ["VT3", "VT5", "VT6", "VT8"]
  end

  def process_after_create
    ## SET FACTURE REF
    self.facture_ref = self.user_financier_subscription_instalment.facture
    self.save
    ## GEN LOG SALE
    LogSale.log_custom_credit(self)
    ## SAVE REFUND
    self.user_financier_subscription_instalment.update(refunded: true, refunded_at: DateTime.now)
  end
end
