class UserFinancierMandate < ApplicationRecord
  belongs_to :user_financier
  validates_uniqueness_of :rum, case_sensitive: true
  after_create :process_after_create

  def self.generate_reference
    return "PIA" + SecureRandom.hex(6).upcase
  end

  def check_iban
    if IBANTools::IBAN.valid?(self.iban) and MyGoCardless.CheckBankDetails(self)
      self.iban = IBANTools::IBAN.new(self.iban).prettify
      self.bic = self.bic.upcase
      return true
    else
      return false
    end
  end

  def process_after_create
    if self.user_financier.user_financier_rib.update(iban: self.iban, bic: self.bic, rum: self.rum)
      self.user_financier.user_financier_mandates.update_all(actif: false)
      self.update(actif: true)
      if self.user_financier.gocardless_customer_id
        MyGoCardless.UpdateCustomerAccountAndMandate(self.user_financier)
      end
    end
  end

  def generate_mandate_pdf
    Dir.mkdir "public/export/" unless (File.exists? ("public/export/"))
    dir = "public/export/"
    file = "MANDAT_SEPA_EARTSUP_#{self.rum}.pdf"
    file_path = dir + file
    pdftk = PdfForms.new()
    iban = IBANTools::IBAN.new(self.iban).code
    pdftk.fill_form "data/mandat-sepa.pdf", file_path, {
      "nom" => self.nom + " " + self.prenom,
      "adresse" => self.adresse,
      "cp" => self.cp,
      "ville" => self.ville,
      "pays" => self.pays,
      "iban1" => iban[0, 4],
      "iban2" => iban[4, 9],
      "iban3" => iban[8, 12],
      "iban4" => iban[12, 16],
      "iban5" => iban[16, 20],
      "iban6" => iban[20, 24],
      "iban7" => iban[24, 27],
      "bic" => self.bic,
      "date" => "#{self.created_at.strftime("%d/%m/%Y")}",
    }, :flatten => true
    return file_path, file
  end
end
