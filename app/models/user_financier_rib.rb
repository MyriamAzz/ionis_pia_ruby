class UserFinancierRib < ApplicationRecord
  belongs_to :user_financier

  before_save :check_iban
  after_update :process_after_update

  def check_iban
    if IBANTools::IBAN.valid?(self.iban) and MyGoCardless.CheckBankDetails(self)
      self.iban = IBANTools::IBAN.new(self.iban).prettify
      self.bic = self.bic.upcase.delete(" ")
    else
      throw(:abort)
    end
  end

  def before_update_rib_gocarldess
    # if self.iban_changed?
    #   MyGoCardless.UpdateCustomerBankAccount(self.user_financier)
    # end
  end

  def process_after_update
    # if (self.saved_changes["iban"] or self.saved_changes["bic"]) and !self.gocardless_account_id.nil?
    #   if MyGoCardless.delay.UpdateCustomerBankAccount(self.user_financier)
    #     MyGoCardless.delay.UpdateCustomerMandate(self.user_financier)
    #   end
    # end
  end
end
