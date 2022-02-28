# encoding: utf-8
class UserFinancierSubscription < ApplicationRecord
  belongs_to :user_financier
  belongs_to :school_year
  belongs_to :formation_annee
  belongs_to :editor, class_name: "User", foreign_key: "updated_by", required: false

  has_many :user_financier_subscription_instalments, dependent: :destroy
  accepts_nested_attributes_for :user_financier_subscription_instalments, reject_if: :all_blank, allow_destroy: true

  has_many :user_financier_subscription_instalment_events, through: :user_financier_subscription_instalments
  has_many :user_financier_subscription_credits, dependent: :destroy
  has_many :log_sales
  has_many :accounting_alerts, dependent: :destroy

  enum s_type: [:inscription, :reinscription]
  enum statut: [:waiting_user, :waiting_admin, :waiting_compta, :active, :done, :canceled, :partial_inscription, :partial_techniques, :demission_before_start, :demission, :exclusion]
  enum payment_mode_inscription: [:prelevement, :virement, :cheque, :cb, :aucun], _prefix: :payment_mode_inscription
  enum payment_mode_scolarite: [:prelevement, :virement, :cheque, :cb, :aucun], _prefix: :payment_mode_scolarite
  enum statut_etu: [:etudiant, :contrat_pro, :apprentissage]
  enum reduction_type: [:all, :one], _prefix: :reduction_type

  before_create :create_process
  # after_create :after_create_process
  after_commit :after_create_process, on: :create
  before_update :before_update_process
  before_destroy :before_destroy_process, prepend: true

  include SearchCop
  search_scope :search do
    attributes "user_financier.etu_nom", "user_financier.etu_prenom"
  end

  def create_process
    if !self.school_year.payment_calendars.where(plan: self.modalite).any? or self.formation_annee.read_attribute("modalite_#{self.modalite}").blank? or self.school_year.frais_inscription_jours.blank?
      throw(:abort)
    end
    self.reduction = 0
    if self.reinscription? && self.etudiant_confirm_reinscription
      self.statut = "waiting_user"
    else
      self.statut = "waiting_compta"
    end
  end

  def after_create_process
    if self.waiting_compta? #or self.waiting_user?
      self.init_instalments_inscription
    end
    if self.waiting_user?
      if self.formation_annee.formation.nom.match(/1/) or self.formation_annee.formation.nom.match(/2/) or self.formation_annee.formation.nom.match(/3/)
        # UserMailer.reinscription_to_student_cycle_1(self).deliver_later
      else
        # UserMailer.reinscription_to_student_cycle_2(self).deliver_later
      end
      # UserMailer.reinscription_to_rf(self).deliver_later
    end
    if Date.today > DateTime.new(self.school_year.debut.year, 11, 1)
      self.accounting_alerts.create(centre_id: self.formation_annee.formation.centre_id, user_id: 0, atype: :alert_late_registration)
    end
    self.user_financier.generate_code_tiers
  end

  def before_update_process
    if self.statut == "active" && self.statut_was != "active"
      self.user_financier_subscription_instalments.where(v_type: :frais_scolarite).each do |instalment|
        instalment.process_active
        if self.reduction > 0 && !instalment.montant_initial.nil?
          LogSale.log_discount(instalment, (instalment.montant_initial - instalment.montant))
        end
      end
    elsif self.partial_inscription? && self.statut_changed?
      self.user_financier_subscription_instalments.where(v_type: :frais_inscription).each do |instalment|
        instalment.process_active
      end
    elsif self.partial_techniques? && self.statut_changed?
      self.user_financier_subscription_instalments.where(v_type: :frais_techniques).each do |instalment|
        instalment.process_active
      end
    elsif self.waiting_compta? && self.statut_was == "waiting_admin"
      self.init_instalments_inscription
      # elsif (self.modalite_changed? or self.reduction_changed?) and !self.active? and !self.done?
      #   if self.user_financier_subscription_instalments.where(v_type: "frais_scolarite", statut: "done").any?
      #     throw :abort
      #   else
      #     if self.reduction_changed?
      #       if self.reduction == 0
      #       self.statut = "waiting_compta"
      #       else
      #       self.statut = "waiting_admin"
      #       end
      #     end
      #     #self.init_instalments_inscription
      #   end
      # else
      #   throw :abort
    end
  end

  def before_destroy_process
    if !self.waiting_admin? and !self.waiting_compta? and !self.waiting_user?
      throw :abort
    end
  end

  def init_instalments_inscription
    # if self.modalite == 1
    #   self.define_inscription_instalments_1
    # elsif self.modalite == 3
    #   self.define_inscription_instalments_3
    # elsif self.modalite == 10
    #   self.define_inscription_instalments_10
    # end
    self.define_instalments
  end

  def define_instalments
    year = self.school_year.debut.year
    registration_fees = self.formation_annee.frais_inscription
    technical_fees = self.formation_annee.frais_technique
    school_fees = self.formation_annee.read_attribute("modalite_#{self.modalite}")
    instalmanent_school_fees = (school_fees / self.modalite)

    if self.redoublant
      school_fees = (school_fees / 2).round
    end
    if self.reduction > 0
      school_fees = school_fees * (1 - (self.reduction / 100.0))
    end

    # montant = montant - self.amount_paid_scolarite

    ## DEFINE FRAIS INSCRIPTION

    if !self.user_financier_subscription_instalments.where(v_type: "frais_inscription").any? && !self.apprentissage? && !self.school_year.frais_inscription_jours.blank?
      instalment = self.user_financier_subscription_instalments.build
      instalment.montant = registration_fees

      if self.payment_mode_inscription_cb_date.nil?
        if self.reinscription? && (Date.today < Date.new(Date.today.year, 7, 5))
          instalment.echeance = Date.new(Date.today.year, 7, 5)
        else
          instalment.echeance = Date.today + self.school_year.frais_inscription_jours.days
        end
      else
        instalment.echeance = self.payment_mode_inscription_cb_date
      end

      instalment.v_type = "frais_inscription"
      instalment.save
      if self.frais_inscription_done
        instalment.process_active
      end
    end

    ## DEFINE FRAIS TECHNIQUES

    if self.etudiant?
      if !self.user_financier_subscription_instalments.where(v_type: "frais_techniques").any? && self.formation_annee.frais_technique > 0 && !self.school_year.frais_techniques_date.blank?
        ## DEFINE FRAIS TECHNIQUE
        instalment = self.user_financier_subscription_instalments.build
        instalment.montant = self.formation_annee.frais_technique
        instalment.echeance = self.school_year.frais_techniques_date
        instalment.v_type = "frais_techniques"
        instalment.save
        if self.frais_techniques_done
          instalment.process_active
        end
      end
    end

    ## DEFINE FRAIS SCOLARITE
    if self.etudiant?
      self.user_financier_subscription_instalments.where(v_type: "frais_scolarite").where.not(statut: [:wip, :done, :failed, :refused]).destroy_all
      (1..self.modalite).each do |n|
        date = school_year.payment_calendars.find_by(plan: self.modalite, plan_order: n).plan_date
        instalment = self.user_financier_subscription_instalments.build
        instalment.montant = instalmanent_school_fees
        if Date.today > date
          instalment.echeance = Date.today + 15.days
        else
          instalment.echeance = date
        end
        instalment.v_type = "frais_scolarite"
        if self.frais_scolarite_done
          instalment.statut = :waiting
        end
        instalment.save
        if self.frais_scolarite_done
          instalment.process_active
        end
      end
    end
  end

  def process_active_subscription
    if MyGoCardless.CreateCustomer(self.user_financier) == false or MyGoCardless.CreateCustomerBankAccount(self.user_financier) == false or MyGoCardless.CreateCustomerMandate(self.user_financier) == false
      return false
    else
      if self.user_financier.user_financier_rib.gocardless_mandate_id
        self.update(statut: "active")
      end
      return true
    end
  end

  def process_active_partial_subscription(stype)
    customer_accounts = self.user_financier.centre.centre_customer_accounts.find_by(school_year_id: self.school_year_id) rescue nil
    if customer_accounts.nil? or customer_accounts.compte_client_sage.blank?
      return false, "Compte client Sage à vide"
    elsif self.formation_annee.formation.compte_produit_sage.blank?
      return false, "Code produit à vide"
    elsif self.user_financier.centre.acronyme.blank?
      return false, "Acronyme campus à vide"
    elsif self.user_financier.centre.code_sage.blank?
      return false, "Code analytique à vide"
    end
    if stype == "frais_inscription_done"
      if self.payment_mode_inscription_prelevement?
        if MyGoCardless.CreateCustomer(self.user_financier) == false or MyGoCardless.CreateCustomerBankAccount(self.user_financier) == false or MyGoCardless.CreateCustomerMandate(self.user_financier) == false
          return false
        else
          if self.user_financier.user_financier_rib.gocardless_mandate_id
            self.update(statut: "partial_inscription", frais_inscription_done: true, frais_inscription_done_date: DateTime.now)
          end
          return true
        end
      else
        self.update(statut: "partial_inscription", frais_inscription_done: true, frais_inscription_done_date: DateTime.now)
        return true
      end
    elsif stype == "frais_techniques_done"
      if self.payment_mode_scolarite_prelevement?
        if MyGoCardless.CreateCustomer(self.user_financier) == false or MyGoCardless.CreateCustomerBankAccount(self.user_financier) == false or MyGoCardless.CreateCustomerMandate(self.user_financier) == false
          return false
        else
          if self.user_financier.user_financier_rib.gocardless_mandate_id
            self.update(statut: "partial_techniques", frais_techniques_done: true, frais_techniques_done_date: DateTime.now)
          end
          return true
        end
      else
        self.update(statut: "partial_techniques", frais_techniques_done: true, frais_techniques_done_date: DateTime.now)
        return true
      end
    elsif stype == "frais_scolarite_done"
      if self.payment_mode_scolarite_prelevement? or self.payment_mode_inscription_prelevement?
        if MyGoCardless.CreateCustomer(self.user_financier) == false or MyGoCardless.CreateCustomerBankAccount(self.user_financier) == false or MyGoCardless.CreateCustomerMandate(self.user_financier) == false
          return false
        else
          if self.user_financier.user_financier_rib.gocardless_mandate_id
            if !self.frais_inscription_done
              self.update(statut: "partial_inscription", frais_inscription_done: true, frais_inscription_done_date: DateTime.now)
            end
            if !self.frais_techniques_done
              self.update(statut: "partial_techniques", frais_techniques_done: true, frais_techniques_done_date: DateTime.now)
            end
            self.update(statut: "active", frais_scolarite_done: true, frais_scolarite_done_date: DateTime.now)
          end
          return true
        end
      else
        if !self.frais_inscription_done
          self.update(statut: "partial_inscription", frais_inscription_done: true, frais_inscription_done_date: DateTime.now)
        end
        if !self.frais_techniques_done
          self.update(statut: "partial_techniques", frais_techniques_done: true, frais_techniques_done_date: DateTime.now)
        end
        self.update(statut: "active", frais_scolarite_done: true, frais_scolarite_done_date: DateTime.now)
        return true
      end
    end
  end

  def modalite_change(modalite, data)
    self.modalite_change_instalments(modalite, data)
  end

  def modalite_change_instalments(modalite, data)
    # Unprocessed
    if self.frais_scolarite_done
      self.user_financier_subscription_instalments.where(v_type: "frais_scolarite", statut: [:inactive, :waiting]).each do |instalment|
        LogSale.log_scolarite_canceled(instalment)
        if self.reduction > 0 && !instalment.montant_initial.nil?
          LogSale.log_discount_canceled(instalment, (instalment.montant_initial - instalment.montant))
        end
      end
    end
    self.update(modalite: modalite)
    self.user_financier_subscription_instalments.where(v_type: "frais_scolarite", statut: [:inactive, :waiting]).destroy_all
    (1..modalite).each do |i|
      if data["#{i}"]
        instalment = self.user_financier_subscription_instalments.build
        if data["#{i}"]["montant_initial"]
          instalment.montant_initial = data["#{i}"]["montant_initial"]
        end
        instalment.montant = data["#{i}"]["montant"]
        instalment.echeance = data["#{i}"]["date"]
        instalment.v_type = "frais_scolarite"
        instalment.save
        if self.frais_scolarite_done
          instalment.process_active_after_change
        end
      end
    end
  end

  def apply_change_formation(formation_annee_id, data)
    # Unprocessed

    if self.frais_techniques_done
      self.user_financier_subscription_instalments.where(v_type: "frais_techniques").each do |instalment|
        LogSale.log_techniques_changed(instalment)
      end
    end
    if self.frais_scolarite_done
      self.user_financier_subscription_instalments.where(v_type: "frais_scolarite").each do |instalment|
        LogSale.log_scolarite_changed(instalment)
        if self.reduction > 0 && !instalment.montant_initial.nil?
          LogSale.log_discount_canceled(instalment, (instalment.montant_initial - instalment.montant))
        end
      end
    end

    formation_annee = FormationAnnee.find(formation_annee_id)

    self.user_financier_subscription_instalments.where(v_type: "frais_techniques", statut: [:inactive, :waiting]).destroy_all

    if formation_annee.frais_technique > 0 && self.etudiant?
      ## DEFINE FRAIS TECHNIQUE
      instalment = self.user_financier_subscription_instalments.build
      instalment.montant = self.formation_annee.frais_technique
      if Date.today >= self.school_year.frais_techniques_date
        instalment.echeance = Date.today + 15.days
      else
        instalment.echeance = self.school_year.frais_techniques_date
      end
      instalment.v_type = "frais_techniques"
      instalment.formation_changed = true
      instalment.save
      if self.frais_techniques_done
        instalment.process_active_after_change
      end
    end

    self.user_financier_subscription_instalments.where(v_type: "frais_scolarite", statut: [:inactive, :waiting]).destroy_all
    (1..modalite).each do |i|
      if !data.nil?
        if data["#{i}"]
          instalment = self.user_financier_subscription_instalments.build
          if data["#{i}"]["montant_initial"]
            instalment.montant_initial = data["#{i}"]["montant_initial"]
          end
          instalment.montant = data["#{i}"]["montant"]
          instalment.echeance = data["#{i}"]["date"]
          instalment.v_type = "frais_scolarite"
          instalment.formation_changed = true
          instalment.save
          if self.frais_scolarite_done
            instalment.process_active_after_change
          end
        end
      end
    end
    self.formation_annee_id = formation_annee_id
    if self.save
      return true
    else
      return false
    end
  end

  def apply_change_statut(instalments, statut)
    if statut == "etudiant"
      self.update(statut_etu: statut, reduction: 0)
      self.init_instalments_inscription
    elsif statut == "contrat_pro"
      ## ANNULER TOUT SAUF INSCRIPTION
      # if self.frais_inscription_done
      #   self.user_financier_subscription_instalments.where(v_type: "frais_inscription").each do |instalment|
      #     instalment.apply_change_statut_etu
      #   end
      # end
      if self.frais_techniques_done
        self.user_financier_subscription_instalments.where(v_type: "frais_techniques").each do |instalment|
          instalment.apply_change_statut_etu
        end
      end
      if self.frais_scolarite_done
        self.user_financier_subscription_instalments.where(v_type: "frais_scolarite").each do |instalment|
          instalment.apply_change_statut_etu
        end
      end
      self.user_financier_subscription_instalments.where(v_type: "frais_techniques", statut: :inactive).destroy_all
      self.user_financier_subscription_instalments.where(v_type: "frais_scolarite", statut: :inactive).destroy_all

      self.update(statut_etu: statut, reduction: 0)
    elsif statut == "apprentissage"
      ## ANNULER TOUT
      if self.frais_inscription_done
        self.user_financier_subscription_instalments.where(v_type: "frais_inscription").each do |instalment|
          instalment.apply_change_statut_etu
        end
      end
      if self.frais_techniques_done
        self.user_financier_subscription_instalments.where(v_type: "frais_techniques").each do |instalment|
          instalment.apply_change_statut_etu
        end
      end
      if self.frais_scolarite_done
        self.user_financier_subscription_instalments.where(v_type: "frais_scolarite").each do |instalment|
          instalment.apply_change_statut_etu
        end
      end

      self.user_financier_subscription_instalments.where(statut: :inactive).destroy_all
      self.update(statut_etu: statut, reduction: 0)
    end
    # self.user_financier_subscription_instalments.where(id: instalments).each do |instalment|
    #   instalment.apply_change_statut_etu
    # end
    # self.init_instalments_inscription

    # if self.frais_inscription_done
    #     self.user_financier_subscription_instalments.where(v_type: "frais_inscription", statut: [:inactive, :waiting]).each do |instalment|
    #       LogSale.log_inscription(instalment)
    #     end
    # end
    # if self.frais_techniques_done
    #   self.user_financier_subscription_instalments.where(v_type: "frais_inscription", statut: [:inactive, :waiting]).each do |instalment|
    #       LogSale.log_techniques(instalment)
    #   end
    # end
    # if self.frais_scolarite_done
    #   self.user_financier_subscription_instalments.where(v_type: "frais_scolarite", statut: [:inactive, :waiting]).each do |instalment|
    #     LogSale.log_scolarite(instalment)
    #   end
    # end
  end

  def apply_discount(mode, discount)
    if mode == "false"
      instalment = self.remaining_instalments_scolarite.first
      instalment = instalment.apply_discount(discount)
      self.reduction = discount.to_i.round
      self.reduction_type = :one
      self.save
    elsif mode == "true"
      instalments = self.remaining_instalments_scolarite
      instalments.each do |instalment|
        instalment = instalment.apply_discount(discount)
      end
      self.reduction = (discount.to_i.round * instalments.count)
      self.reduction_type = :all
      self.save
    end
  end

  def apply_closure(instalments, type)
    if type == "0"
      self.update(statut: :demission_before_start)
    elsif type == "1"
      self.update(statut: :demission)
    elsif type == "2"
      self.update(statut: :exclusion)
    end
    self.user_financier_subscription_instalments.where(id: instalments).each do |instalment|
      instalment.apply_closure
    end

    self.user_financier_subscription_instalments.each do |instalment|
      if !instalment.is_in_process_gocardless
        instalment.update(statut: :canceled)
      end
    end
  end

  def cancel_closure
    if self.frais_scolarite_done
      self.update(statut: :partial_inscription)
      self.update(statut: :partial_techniques)
      self.update(statut: :active)
    elsif self.frais_inscription_done
      self.update(statut: :partial_inscription)
    else
      self.update(statut: :waiting_compta)
    end
  end

  def transfer_campus_formation(new_formation_annee)
    remaining_instalments = self.remaining_instalments_to_paid_scolarite
    if remaining_instalments.count == 0
    else
      if self.frais_scolarite_done
        self.user_financier_subscription_instalments.where(v_type: "frais_scolarite").each do |instalment|
          LogSale.log_scolarite_transfer(instalment)
          if self.reduction > 0 && !instalment.montant_initial.nil?
            LogSale.log_discount_canceled(instalment, (instalment.montant_initial - instalment.montant))
          end
        end
      end
      if self.frais_inscription_done
        self.user_financier_subscription_instalments.where(v_type: "frais_inscription").each do |instalment|
          LogSale.log_inscription_transfer(instalment)
        end
      end
      if self.frais_techniques_done
        self.user_financier_subscription_instalments.where(v_type: "frais_inscription").each do |instalment|
          LogSale.log_techniques_transfer(instalment)
        end
      end

      new_amout = new_formation_annee.read_attribute("modalite_#{self.modalite}")

      reste = (new_amout - self.amount_paid_scolarite).round
      instalment_reste = (reste / remaining_instalments.count).round

      remaining_instalments.each do |instalment|
        instalment.update(montant: instalment_reste)
      end

      self.update(reduction: 0, formation_annee_id: new_formation_annee.id)

      if self.frais_scolarite_done
        self.user_financier_subscription_instalments.where(v_type: "frais_scolarite").each do |instalment|
          LogSale.log_scolarite(instalment)
        end
      end
      if self.frais_inscription_done
        self.user_financier_subscription_instalments.where(v_type: "frais_inscription").each do |instalment|
          LogSale.log_inscription(instalment)
        end
      end
      if self.frais_techniques_done
        self.user_financier_subscription_instalments.where(v_type: "frais_inscription").each do |instalment|
          LogSale.log_techniques(instalment)
        end
      end
    end
    return true
  end

  def is_frais_inscription_payed
    done = false
    self.user_financier_subscription_instalments.where(v_type: "frais_inscription").each do |instalment|
      if instalment.done?
        done = true
      else
        done = false
      end
    end
    return done
  end

  def can_update
    if !self.demission_before_start? && !self.demission? && !self.exclusion? && !self.done? && !self.canceled?
      return true
    else
      return false
    end
  end

  def can_update_instalments
    if !self.done? && !self.canceled?
      return true
    else
      return false
    end
  end

  def can_cancel
    if self.waiting_user? or self.waiting_admin? or self.waiting_compta?
      return true
    else
      return false
    end
  end

  def remaining_amount_to_pay_scolarite
    return self.user_financier_subscription_instalments.where(v_type: [:frais_scolarite], statut: [:inactive, :waiting, :refused]).sum(:montant)
  end

  def remaining_discount_to_deduct
    i = 0
    self.user_financier_subscription_instalments.where(v_type: [:frais_scolarite], statut: [:inactive, :waiting]).where.not(montant_initial: nil).each do |instalment|
      i += (instalment.montant_initial - instalment.montant)
    end
    return i
  end

  def amount_paid_scolarite
    return self.user_financier_subscription_instalments.where(v_type: [:frais_scolarite], statut: [:wip, :done]).sum(:montant)
  end

  def remaining_instalments_to_paid_scolarite
    return self.user_financier_subscription_instalments.where(v_type: [:frais_scolarite], statut: [:inactive, :waiting])
  end

  def remaining_amount_to_pay_closure
    return self.user_financier_subscription_instalments.where(v_type: [:frais_scolarite, :frais_techniques], statut: [:inactive, :waiting, :refused]).sum(:montant)
  end

  def amount_paid_closure
    return self.user_financier_subscription_instalments.where(statut: [:wip, :done]).sum(:montant)
  end

  def remaining_instalments_scolarite
    return self.user_financier_subscription_instalments.where(v_type: [:frais_scolarite], statut: [:inactive, :waiting, :refused])
  end

  def get_num_invoice_pro_forma
    # return self. + self.id
  end

  def self.csv_export_ca
    headers = ["CAMPUS", "ANNEE SCOLAIRE", "ETUDIANT", "CODE TIERS", "FORMATION", "MONTANT CA", "STATUT SOUSCRIPTION"]
    file = CSV.generate(write_headers: true, headers: headers, converters: :all, :col_sep => ";") do |csv|
      all.each do |data|
        #amount = data.log_sales.where(statut: [:waiting, :wip, :done, :refused, :failed]).sum(:montant)
        debit = data.log_sales.where.not(date_echeance: nil).sum(:debit)
        credit = data.log_sales.where.not(date_echeance: nil).sum(:credit)
        amount = (debit - credit)
        csv << [data.formation_annee.formation.centre.nom, data.school_year.nom, data.user_financier.etu_nom_prenom, data.user_financier.code_tiers, data.formation_annee.formation.nom, amount, data.statut_humanized]
      end
    end
  end

  def self.csv_export_alert_frais_scolarite
    headers = ["CAMPUS", "ANNEE SCOLAIRE", "ETUDIANT", "CODE TIERS", "FORMATION", "MONTANT FORMATION", "CA ENREGISTRE", "STATUT SOUSCRIPTION", "STATUT ETUDIANT"]
    file = CSV.generate(write_headers: true, headers: headers, converters: :all, :col_sep => ";") do |csv|
      all.each do |data|
        #amount = data.log_sales.where(statut: [:waiting, :wip, :done, :refused, :failed]).sum(:montant)
        logs = data.log_sales.joins(:user_financier_subscription_instalment).where.not(date_echeance: nil).where("user_financier_subscription_instalments.v_type = ?", 1)
        debit = logs.sum(:debit)
        credit = logs.sum(:credit)
        amount = (debit - credit)
        if amount != data.formation_annee.read_attribute("modalite_#{data.modalite}")
          csv << [data.formation_annee.formation.centre.nom, data.school_year.nom, data.user_financier.etu_nom_prenom, data.user_financier.code_tiers, data.formation_annee.formation.nom, data.formation_annee.read_attribute("modalite_#{data.modalite}"), amount, data.statut_humanized, data.statut_etu.humanize]
        end
      end
    end
  end

  def self.select_statut_humanized
    return ["En attente étudiant/financier", "En attente administrateur", "En attente comptabilité",
            "Actif", "Terminé", "Annulé", "Traitement comptable partiel", "Traitement comptable partiel", "Démission avant rentrée scolaire", "Démission", "Exclusion"]
  end

  def statut_humanized
    tab = { "waiting_user" => "En attente étudiant/financier", "waiting_admin" => "En attente administrateur", "waiting_compta" => "En attente comptabilité",
            "active" => "Actif", "done" => "Terminé", "canceled" => "Annulé", "partial_inscription" => "Traitement comptable partiel", "partial_techniques" => "Traitement comptable partiel", "demission_before_start" => "Démission avant rentrée scolaire", "demission" => "Démission", "exclusion" => "Exclusion" }
    return tab[self.statut]
  end

  def statut_financier_humanized
    tab = { "waiting_user" => "En attente étudiant/financier", "waiting_admin" => "En attente administrateur", "waiting_compta" => "En attente du traitement comptable",
            "active" => "Formation en cours", "done" => "Terminé", "canceled" => "Annulé", "partial_inscription" => "Traitement comptable partiel", "partial_techniques" => "Traitement comptable partiel", "demission_before_start" => "Démission avant rentrée scolaire", "demission" => "Démission", "exclusion" => "Exclusion" }
    return tab[self.statut]
  end

  def statut_humanized_label
    if self.waiting_user?
      return "<span
        class='label label-inline label-lg label-warning font-weight-bolder'>#{self.statut_humanized}</span>"
    elsif self.waiting_admin?
      return "<span
        class='label label-inline label-lg label-warning font-weight-bolder'>#{self.statut_humanized}</span>"
    elsif self.waiting_compta?
      return "<span
        class='label label-inline label-lg label-warning font-weight-bolder'>#{self.statut_humanized}</span>"
    elsif self.active?
      return "<span
        class='label label-inline label-lg label-success font-weight-bolder'>#{self.statut_humanized}</span>"
    elsif self.done?
      return "<span
        class='label label-inline label-lg label-success font-weight-bolder'>#{self.statut_humanized}</span>"
    elsif self.canceled?
      return "<span
        class='label label-inline label-lg label-success font-weight-bolder'>#{self.statut_humanized}</span>"
    elsif self.partial_inscription?
      return "<span
        class='label label-inline label-lg label-warning font-weight-bolder'>#{self.statut_humanized}</span>"
    elsif self.partial_techniques?
      return "<span
          class='label label-inline label-lg label-warning font-weight-bolder'>#{self.statut_humanized}</span>"
    elsif self.demission_before_start?
      return "<span
          class='label label-inline label-lg label-danger font-weight-bolder'>#{self.statut_humanized}</span>"
    elsif self.demission?
      return "<span
            class='label label-inline label-lg label-danger font-weight-bolder'>#{self.statut_humanized}</span>"
    elsif self.exclusion?
      return "<span
                    class='label label-inline label-lg label-danger font-weight-bolder'>#{self.statut_humanized}</span>"
    end
    return tab[self.statut]
  end

  def statut_financier_humanized_label
    if self.waiting_user?
      return "<span
      class='btn btn-warning btn-sm font-weight-bold btn-upper btn-text'>#{self.statut_financier_humanized}</span>"
    elsif self.waiting_admin?
      return "<span
      class='btn btn-success btn-sm font-weight-bold btn-upper btn-text'>#{self.statut_financier_humanized}</span>"
    elsif self.waiting_compta?
      return "<span
      class='btn btn-inline btn-sm btn-warning font-weight-bolder'>#{self.statut_financier_humanized}</span>"
    elsif self.active?
      return "<span
      class='btn btn-inline btn-sm btn-success font-weight-bold'>#{self.statut_financier_humanized}</span>"
    elsif self.done?
      return "<span
      class='btn btn-success btn-sm font-weight-bold btn-upper btn-text'>#{self.statut_financier_humanized}</span>"
    elsif self.canceled?
      return "<span
      class='btn btn-success btn-sm font-weight-bold btn-upper btn-text'>#{self.statut_financier_humanized}</span>"
    elsif self.partial_inscription?
      return "<span
      class='btn btn-warning btn-sm font-weight-bold btn-upper btn-text'>#{self.statut_financier_humanized}</span>"
    elsif self.partial_techniques?
      return "<span
      class='btn btn-warning btn-sm font-weight-bold btn-upper btn-text'>#{self.statut_financier_humanized}</span>"
    elsif self.demission_before_start?
      return "<span
      class='btn btn-danger btn-sm font-weight-bold btn-upper btn-text'>#{self.statut_financier_humanized}</span>"
    elsif self.demission?
      return "<span
      class='btn btn-danger btn-sm font-weight-bold btn-upper btn-text'>#{self.statut_financier_humanized}</span>"
    elsif self.exclusion?
      return "<span
        class='btn btn-danger btn-sm font-weight-bold btn-upper btn-text'>#{self.statut_financier_humanized}</span>"
    end
    return tab[self.statut]
  end

  def select_month_start
    start = 2020
    tab = []
    (start..(start + 2)).each do |s|
      tab << ["Septembre #{s}"]
      tab << ["Février #{s}"]
    end
    return tab
  end
end
