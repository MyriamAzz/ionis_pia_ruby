# encoding: utf-8
class UserFinancierSubscriptionInstalment < ApplicationRecord
  require "csv"
  validates_uniqueness_of :facture, case_sensitive: true, allow_nil: true

  belongs_to :user_financier_subscription
  belongs_to :payout, required: false

  has_many :log_sales
  has_many :user_financier_subscription_instalment_events, -> { order(gocardless_date: :asc) }

  enum statut: [:inactive, :waiting, :wip, :done, :refused, :failed, :canceled]
  enum v_type: [:frais_inscription, :frais_scolarite, :frais_techniques]
  enum v_mode: [:prelevement, :virement, :cheque, :cb, :aucun]

  before_create :before_create_process
  after_create :after_create_process
  before_update :before_update_process

  scope :export_done_failed, -> { where(v_mode: [:prelevement, :cb], statut: [:done, :refused, :failed], exported: false) }
  scope :export_done_failed_all, -> { where(v_mode: [:prelevement, :cb], statut: [:done, :refused, :failed]) }

  scope :stat_not_invoiced, -> { where(refunded: false).where(statut: :inactive) }
  scope :stat_invoiced, -> { where(refunded: false).where("`user_financier_subscription_instalments`.`statut` IN (1, 2, 3) OR (`user_financier_subscription_instalments`.`statut` = 4 AND `rescheduled` = 0) OR (`user_financier_subscription_instalments`.`statut` = 5 AND `rescheduled` = 0)") }
  scope :stat_collected, -> { where(refunded: false).where(statut: :done) }
  scope :stat_not_expired, -> { where(refunded: false).where("(DATE_ADD(echeance, INTERVAL 15 DAY)) > ?", Date.today).where("`user_financier_subscription_instalments`.`statut` IN (1, 2) OR (`user_financier_subscription_instalments`.`statut` = 4 AND `rescheduled` = 0) OR (`user_financier_subscription_instalments`.`statut` = 5 AND `rescheduled` = 0)") }
  scope :stat_expired, -> { where(refunded: false).where("(DATE_ADD(echeance, INTERVAL 15 DAY)) < ?", Date.today).where("`user_financier_subscription_instalments`.`statut` IN (1, 2) OR (`user_financier_subscription_instalments`.`statut` = 4 AND `rescheduled` = 0) OR (`user_financier_subscription_instalments`.`statut` = 5 AND `rescheduled` = 0)") }
  scope :stat_expired_all, -> { where(refunded: false).where("echeance < ?", Date.today).where("`user_financier_subscription_instalments`.`statut` IN (1, 2) OR (`user_financier_subscription_instalments`.`statut` = 4 AND `rescheduled` = 0) OR (`user_financier_subscription_instalments`.`statut` = 5 AND `rescheduled` = 0)") }
  scope :stat_turnover, -> { where(refunded: false).where(v_type: :frais_scolarite).where("`user_financier_subscription_instalments`.`statut` IN (1, 2, 3) OR (`user_financier_subscription_instalments`.`statut` = 4 AND `rescheduled` = 0) OR (`user_financier_subscription_instalments`.`statut` = 5 AND `rescheduled` = 0)") }

  def before_create_process
    if self.v_mode.nil?
      if self.frais_inscription?
        self.v_mode = self.user_financier_subscription.payment_mode_inscription
      elsif self.frais_techniques? or self.frais_scolarite?
        self.v_mode = self.user_financier_subscription.payment_mode_scolarite
      end
    end
    self.validate_params
  end

  def after_create_process
    if self.statut.nil?
      self.statut = "inactive"
      self.save
    end
    if self.custom_line
      if (self.user_financier_subscription.frais_inscription_done && self.frais_inscription?) or
         (self.user_financier_subscription.frais_techniques_done && self.frais_techniques?) or
         (self.user_financier_subscription.frais_scolarite_done && self.frais_scolarite?)
        self.process_active
      end
    end
  end

  def before_update_process
    self.validate_params
  end

  def validate_params
    # if self.facture.blank? && ()

    if (self.virement? or self.cheque? or self.cb? or self.aucun?) && (self.wip? or self.failed? or self.refused?)
      throw :abort
    elsif self.prelevement? && (self.wip? or self.done? or self.failed? or self.refused?) && self.gocardless_id.nil?
      throw :abort
    elsif self.prelevement? && self.waiting? && self.facture.blank? && !self.custom_line
      throw :abort
    elsif self.montant < 0
      throw :abort
    end
  end

  def generate_ref_facture
    if self.facture.blank?
      centre = self.user_financier_subscription.formation_annee.formation.centre
      centre_customer_account = centre.centre_customer_accounts.find_by(school_year: self.user_financier_subscription.school_year)
      num = centre_customer_account.num_facture.to_s.rjust(6, "0")
      if self.update(facture: "I#{centre.acronyme}#{self.user_financier_subscription.school_year.nom[2..3]}#{num}".upcase)
        centre_customer_account.increment!(:num_facture)
      end
    end
  end

  def process_active
    self.generate_ref_facture
    if !self.is_in_process_gocardless
      if self.inactive? && !self.cb?
        self.update(statut: "waiting")
      elsif self.inactive? && self.cb?
        self.update(statut: "done")
      elsif !self.custom_line or (self.custom_line && self.prelevement?)
        self.update(statut: "waiting")
      end
    end
    if self.need_accounted
      case self.v_type
      when "frais_inscription"
        LogSale.log_inscription(self)
      when "frais_techniques"
        LogSale.log_techniques(self)
      when "frais_scolarite"
        LogSale.log_scolarite(self)
      end
      self.update(refunded: false, refunded_at: nil)
    end
  end

  def force_turnover
    case self.v_type
    when "frais_inscription"
      LogSale.log_inscription(self)
    when "frais_techniques"
      LogSale.log_techniques(self)
    when "frais_scolarite"
      LogSale.log_scolarite(self)
    end
    return true
  end

  def process_active_after_change
    if self.inactive?
      self.generate_ref_facture
      self.update(statut: "waiting")
    end
    if self.need_accounted
      case self.v_type
      when "frais_inscription"
        LogSale.log_inscription(self)
      when "frais_techniques"
        LogSale.log_techniques(self)
      when "frais_scolarite"
        LogSale.log_scolarite(self)
        if !self.montant_initial.nil?
          LogSale.log_discount(self, (self.montant_initial - self.montant))
        end
      end
      self.update(refunded: false, refunded_at: nil)
    end
  end

  def is_in_process_gocardless
    if self.wip? or self.done? or self.refused?
      return true
    else
      return false
    end
  end

  def apply_discount(discount)
    if self.user_financier_subscription.frais_scolarite_done
      LogSale.log_discount(self, discount)
    end
    self.montant_initial = self.montant
    self.montant = self.montant - discount.to_i
    self.save
  end

  def apply_change_statut_etu
    if self.need_accounted
      if self.frais_inscription? && self.user_financier_subscription.frais_inscription_done
        LogSale.log_inscription_change_statut_etu(self)
        self.update(refunded: true, refunded_at: DateTime.now)
      elsif self.frais_techniques? && self.user_financier_subscription.frais_techniques_done
        LogSale.log_techniques_change_statut_etu(self)
        self.update(refunded: true, refunded_at: DateTime.now)
      elsif self.frais_scolarite? && self.user_financier_subscription.frais_scolarite_done
        LogSale.log_scolarite_change_statut_etu(self)
        self.update(refunded: true, refunded_at: DateTime.now)
        if self.user_financier_subscription.reduction > 0 && !self.montant_initial.nil?
          LogSale.log_discount_canceled(self, (self.montant_initial - self.montant))
        end
      end
    end
    if !self.is_in_process_gocardless
      self.destroy
    else
      self.update(refunded: true, refunded_at: DateTime.now)
    end
  end

  def apply_closure
    if self.need_accounted
      if self.frais_inscription? && self.user_financier_subscription.frais_inscription_done
        LogSale.log_inscription_closure(self)
        self.update(refunded: true, refunded_at: DateTime.now)
      elsif self.frais_techniques? && self.user_financier_subscription.frais_techniques_done
        LogSale.log_techniques_closure(self)
        self.update(refunded: true, refunded_at: DateTime.now)
      elsif self.frais_scolarite? && self.user_financier_subscription.frais_scolarite_done
        LogSale.log_scolarite_closure(self)
        self.update(refunded: true, refunded_at: DateTime.now)
      end
    end
  end

  def apply_retry(date, montant)
    if MyGoCardless.RetryPayment(self, date)
      self.update(montant: montant, echeance: date)
      self.user_financier_subscription_instalment_events.where(gocardless_status: :failed).update(done: true)
      return true
    else
      return false
    end
  end

  def self.GoCardlessDaily
    self.where(echeance: (Date.today + 3.days), v_mode: :prelevement, statut: :waiting).where("montant > ?", 0).each do |instalment|
      if MyGoCardless.CreateCustomer(instalment.user_financier_subscription.user_financier) == false or MyGoCardless.CreateCustomerBankAccount(instalment.user_financier_subscription.user_financier) == false or MyGoCardless.CreateCustomerMandate(instalment.user_financier_subscription.user_financier) == false
      else
        MyGoCardless.CreateOneTimePayment(instalment)
      end
    end
  end

  def self.csv_export_all
    headers = ["CAMPUS", "FACTURE", "ETAT", "LIBELLE", "MONTANT", "MODE", "DATE ECHEANCE", "CODE TIERS", "RF", "EMAIL RF", "ETUDIANT", "STATUT ETUDIANT", "MANDAT", "STATUT SOUSCRIPTION"]

    file = CSV.generate(write_headers: true, headers: headers, converters: :all, :col_sep => ";") do |csv|
      all.each do |data|
        financier = data.user_financier_subscription.user_financier
        if financier.user_financier_rib && !financier.user_financier_rib.gocardless_mandate_id.nil?
          mandate = "Actif"
        else
          mandate = "Sans"
        end
        csv << [financier.centre.nom, data.facture, data.statut_humanized, data.v_type_humanized, data.montant, data.v_mode.humanize, data.echeance.strftime("%d/%m/%Y"), financier.code_tiers, financier.rf_nom_prenom, financier.user.email, financier.etu_nom_prenom, data.user_financier_subscription.statut_etu.upcase, mandate, data.user_financier_subscription.statut_humanized]
      end
    end
  end

  def self.csv_export_expired(without_date = false)
    headers = ["CAMPUS", "FACTURE", "ETAT", "LIBELLE", "MONTANT", "MODE", "DATE ECHEANCE", "CODE TIERS", "RF", "EMAIL RF", "ETUDIANT", "STATUT ETUDIANT", "MANDAT", "STATUT SOUSCRIPTION", "RELANCER", "COMMENTAIRE FINANCIER"]
    if without_date
      instalments = all.stat_expired_all
    else
      instalments = all.stat_expired
    end
    file = CSV.generate(write_headers: true, headers: headers, converters: :all, :col_sep => ";") do |csv|
      instalments.each do |data|
        financier = data.user_financier_subscription.user_financier
        if financier.user_financier_rib && !financier.user_financier_rib.gocardless_mandate_id.nil?
          mandate = "Actif"
        else
          mandate = "Sans"
        end
        csv << [financier.centre.nom,
                data.facture,
                data.statut_humanized,
                data.v_type_humanized,
                data.montant,
                data.v_mode.humanize,
                data.echeance.strftime("%d/%m/%Y"),
                financier.code_tiers,
                financier.rf_nom_prenom,
                financier.user.email,
                financier.etu_nom_prenom,
                data.user_financier_subscription.statut_etu.upcase,
                mandate,
                data.user_financier_subscription.statut_humanized,
                (financier.dont_relaunch ? "Non" : "Oui"),
                (data.user_financier_subscription.user_financier.user_financier_timelines.where(comment_pin: true).last.descr rescue "")]
      end
    end
  end

  def self.csv_export_done_failed(tag, all_rows)
    file = CSV.generate(converters: :all, :col_sep => ";") do |csv|
      if all_rows
        rows = all.export_done_failed_all
      else
        rows = all.export_done_failed
      end
      rows.each do |data|
        case data.v_type
        when "frais_inscription"
          libelle = "1er Frais de scolarite"
          type_frais = 2
        when "frais_techniques"
          libelle = "Frais annexes Techniques"
          type_frais = 3
        when "frais_scolarite"
          pos = data.user_financier_subscription.user_financier_subscription_instalments.where(v_type: :frais_scolarite).map(&:id).index(data.id)
          if (pos + 1) == 1
            libelle = "1er Prelevement sco"
          else
            libelle = (pos + 1).to_s + "eme Prelevement sco"
          end
          type_frais = 2
        end

        code = "BN"
        reference = data.generate_reference
        compte_general = data.user_financier_subscription.formation_annee.formation.centre.compte_client_sage
        compte_tiers = data.user_financier_subscription.user_financier.code_tiers
        type_ecriture = "G"
        analytique = ""
        mode_reglement = data.v_mode.humanize
        date_echeance = data.echeance.strftime("%d/%m/%Y")
        date_import = Date.today.strftime("%d/%m/%Y")

        montant = data.montant

        if data.done?
          debit = 0
          credit = montant
          debit_1 = montant
          credit_1 = 0
          rejet = ""

          nom_complet = I18n.transliterate(data.user_financier_subscription.user_financier.etu_nom_prenom)
          annee = data.user_financier_subscription.school_year.nom.split("/")[0]

          csv << [code, date_import, data.facture, reference, compte_general, compte_tiers, libelle, type_ecriture,
                  analytique, mode_reglement, date_echeance, debit, credit, nom_complet, annee, type_frais,
                  data.user_financier_subscription.modalite, rejet]

          compte_general = 51111000
          compte_tiers = ""

          csv << [code, date_import, data.facture, reference, compte_general, compte_tiers, libelle, type_ecriture,
                  analytique, "", date_echeance, debit_1, credit_1, nom_complet, annee, type_frais,
                  data.user_financier_subscription.modalite, rejet]
        else
          debit = montant
          credit = 0
          debit_1 = 0
          credit_1 = montant
          rejet = 1

          nom_complet = data.user_financier_subscription.user_financier.etu_nom_prenom
          annee = data.user_financier_subscription.school_year.nom.split("/")[0]

          csv << [code, date_import, data.facture, reference, compte_general, compte_tiers, libelle, type_ecriture,
                  analytique, mode_reglement, date_echeance, debit, credit, nom_complet, annee, type_frais,
                  data.user_financier_subscription.modalite, rejet]

          compte_general = 51111000
          compte_tiers = ""

          csv << [code, date_import, data.facture, reference, compte_general, compte_tiers, libelle, type_ecriture,
                  analytique, "", date_echeance, debit_1, credit_1, nom_complet, annee, type_frais,
                  data.user_financier_subscription.modalite, rejet]

          compte_general = data.user_financier_subscription.formation_annee.formation.centre.compte_client_sage
          compte_tiers = data.user_financier_subscription.user_financier.code_tiers
          debit = 0
          credit = montant
          debit_1 = montant
          credit_1 = 0
          rejet = ""

          nom_complet = data.user_financier_subscription.user_financier.etu_nom_prenom
          annee = data.user_financier_subscription.school_year.nom.split("/")[0]

          csv << [code, date_import, data.facture, reference, compte_general, compte_tiers, libelle, type_ecriture,
                  analytique, mode_reglement, date_echeance, debit, credit, nom_complet, annee, type_frais,
                  data.user_financier_subscription.modalite, rejet]

          compte_general = 51111000
          compte_tiers = ""

          csv << [code, date_import, data.facture, reference, compte_general, compte_tiers, libelle, type_ecriture,
                  analytique, "", date_echeance, debit_1, credit_1, nom_complet, annee, type_frais,
                  data.user_financier_subscription.modalite, rejet]
        end
      end
    end
    if !all_rows && tag
      export_done_failed.update_all(exported: true)
    end
    return file
  end

  def generate_reference
    return self.user_financier_subscription.formation_annee.formation.code + " " + self.user_financier_subscription.formation_annee.formation.centre.acronyme.upcase
  end

  def self.statut_form_select
    tab = [["Non facturé", "inactive"], ["En attente", "waiting"], ["En cours", "wip"], ["Effectué", "done"], ["Refusé", "refused"], ["Échoué", "failed"], ["Annulé", "canceled"]]
  end

  def statut_humanized
    tab = { "inactive" => "Non facturée", "waiting" => "En attente", "wip" => "En cours",
            "done" => "Payée", "refused" => "Refusée", "failed" => "Échouée", "canceled" => "Annulée" }
    return tab[self.statut]
  end

  def statut_user_humanized
    tab = { "inactive" => "Non facturé", "waiting" => "En attente", "wip" => "En cours",
            "done" => "Payé", "refused" => "Refusé", "failed" => "Échoué", "canceled" => "Annulé" }
    return tab[self.statut]
  end

  def v_type_humanized
    tab = { "frais_inscription" => "1er Frais scolarité", "frais_techniques" => "Frais techniques", "frais_scolarite" => "Frais scolarité" }
    return tab[self.v_type]
  end

  def statut_humanized_label
    if self.inactive?
      return "<span
        class='label label-inline label-default font-weight-bold'>#{self.statut_humanized}</span>"
    elsif self.waiting? && (self.echeance + 15.days) < Date.today
      return "<span
            class='label label-inline label-warning font-weight-bold'>#{self.statut_humanized}</span>"
    elsif self.waiting?
      return "<span
        class='label label-inline label-primary font-weight-bold'>#{self.statut_humanized}</span>"
    elsif self.wip?
      return "<span
        class='animate__animated animate__pulse animate__infinite label label-inline label-warning font-weight-bold'>#{self.statut_humanized}</span>"
    elsif self.done?
      return "<span
        class='label label-inline label-success font-weight-bold'>#{self.statut_humanized}</span>"
    elsif self.refused?
      return "<span
        class='label label-inline label-danger font-weight-bold'>#{self.statut_humanized}</span>"
    elsif self.failed?
      return "<span
        class='label label-inline label-danger font-weight-bold'>#{self.statut_humanized}</span>"
    elsif self.canceled?
      return "<span
        class='label label-inline label-danger font-weight-bold'>#{self.statut_humanized}</span>"
    end
    return tab[self.statut]
  end

  def statut_user_humanized_label
    if self.inactive?
      return "<button class='btn btn-sm btn-default'><span
        class=''>#{self.statut_humanized}</span></button>"
    elsif self.waiting?
      return "<button class='btn btn-sm btn-light-primary'><span
        class=''>#{self.statut_humanized}</span></button>"
    elsif self.wip?
      return "<button class='btn btn-sm btn-light-warning'><span
        >#{self.statut_humanized}</span></button>"
    elsif self.done?
      return "<button class='btn btn-sm btn-light-success'><span
       >#{self.statut_humanized}</span></button>"
    elsif self.refused?
      return "<button class='btn btn-sm btn-light-danger'><span
        >#{self.statut_humanized}</span></button>"
    elsif self.failed?
      return "<button class='btn btn-sm btn-light-danger'><span
        >#{self.statut_humanized}</span></button>"
    elsif self.canceled?
      return "<button class='btn btn-sm btn-light-danger'><span
        >#{self.statut_humanized}</span></button>"
    end
    return tab[self.statut]
  end

  def can_canceled_closure
    if (self.inactive? or self.waiting?) && (self.user_financier_subscription.demission? or self.user_financier_subscription.demission_before_start? or self.user_financier_subscription.exclusion?)
      return true
    else
      return false
    end
  end
end
