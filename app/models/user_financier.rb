#encoding: utf-8
class UserFinancier < ApplicationRecord
  belongs_to :centre, required: false
  belongs_to :user

  validates_uniqueness_of :etu_id_sf, case_sensitive: true, :allow_nil => true
  validates_uniqueness_of :code_tiers, case_sensitive: true, :allow_nil => true

  has_one :user_financier_rib, dependent: :destroy
  accepts_nested_attributes_for :user_financier_rib

  has_many :user_financier_subscriptions, dependent: :destroy
  has_many :user_financier_timelines, -> { order(created_at: :desc) }, dependent: :destroy
  has_many :user_financier_rib_events, dependent: :destroy
  has_many :user_financier_mandates, dependent: :destroy

  before_save :format_data
  # after_create :process_after_create
  after_commit :process_after_commit_create, on: :create
  before_update :process_before_update
  after_update :process_after_update

  include SearchCop
  search_scope :search do
    attributes :etu_nom, :etu_email, :etu_prenom
  end

  def user_financier_rib
    super || build_user_financier_rib
  end

  def format_data
    self.nom.upcase! rescue nil
    self.prenom = self.prenom.titleize rescue nil
    self.adresse.upcase! rescue nil
    self.ville.upcase! rescue nil
    self.pays.upcase! rescue nil
    self.etu_nom.upcase! rescue nil
    self.etu_prenom = self.etu_prenom.titleize rescue nil
    self.etu_adresse.upcase! rescue nil
    self.etu_ville.upcase! rescue nil
    self.etu_pays.upcase! rescue nil
    self.etu_famille_ionis.upcase! rescue nil
    self.etu_famille_ionis_nom.upcase! rescue nil
    self.etu_famille_ionis_prenom = self.etu_famille_ionis_prenom.titleize rescue nil
  end

  def process_after_commit_create
    if !self.imported
      password = Devise.friendly_token.first(10)
      self.user.update(password: password)
      UserMailer.send_credentials(self.user, password).deliver_later
    end
  end

  def process_before_update
    if self.dont_relaunch_changed? && !self.dont_relaunch
      self.dont_relaunch_comment = nil
    end
  end

  def process_after_update
    # if self.code_tiers.nil?
    #   self.code_tiers = self.generate_code_tiers
    #   self.save
    # end
    if (self.saved_changes["nom"] or self.saved_changes["prenom"] or self.saved_changes["etu_prenom"] or self.saved_changes["etu_nom"] or self.saved_changes["centre_id"]) and !self.gocardless_customer_id.nil?
      MyGoCardless.delay.UpdateCustomer(self)
    end
  end

  def generate_code_tiers
    if self.code_tiers.nil? && !self.user_financier_subscriptions.last.nil?
      year = self.user_financier_subscriptions.last.formation_annee.school_year.debut.strftime("%Y")
      code = year + "PIA" + self.user.id.to_s + self.id.to_s
      self.update(code_tiers: code)
    end
  end

  def api_create_subscription_inscription(centre, formation_id, school_year_s, modalite, mode_inscription, mode_inscription_comment, mode_scolarite, mode_scolarite_comment, payment_date_cb)
    begin
      formation_temp = Formation.find_by_code(formation_id)
      formation = Formation.where(centre_id: centre.id, nom: formation_temp.nom).first
      school_year = SchoolYear.find_by_nom(school_year_s)
      formation_annee = formation.formation_annees.where(school_year_id: school_year.id).first
      subscription = self.user_financier_subscriptions.build
      subscription.formation_annee_id = formation_annee.id
      subscription.school_year_id = school_year.id
      subscription.s_type = :inscription
      subscription.statut_etu = :etudiant
      subscription.reduction = 0
      if modalite == "De la totalité"
        modalite = 1
      elsif modalite == "En 3 fois"
        modalite = 3
      elsif modalite == "En 10 mensualités"
        modalite = 10
      end
      subscription.modalite = modalite
      subscription.payment_mode_inscription = mode_inscription.parameterize
      if mode_inscription.parameterize == "cb"
        subscription.payment_mode_inscription_cb_date = payment_date_cb.to_date rescue nil
      end
      subscription.payment_mode_inscription_comment = mode_inscription_comment
      subscription.payment_mode_scolarite = mode_scolarite.parameterize
      subscription.payment_mode_scolarite_comment = mode_scolarite_comment
      if !mode_inscription_comment.blank? or !mode_scolarite_comment.blank?
        subscription.special_case = true
      end
      if subscription.save
        return true
      else
        return false
      end
    rescue
      return false
    end
  end

  def import_create_subscription(centre, souscription_type, formation_id, school_year_b, school_year_d, statut_etu, modalite, confirm_reinscription, send_credentials)
    begin
      formation = Formation.where(centre_id: centre.id, code: formation_id).first
      school_year_base = self.centre.school_program.school_years.find_by_nom(school_year_b)
      school_year_subscription = self.centre.school_program.school_years.find_by_nom(school_year_d)
      formation_annee = formation.formation_annees.where(school_year_id: school_year_base.id).first
      subscription = self.user_financier_subscriptions.build
      subscription.formation_annee_id = formation_annee.id
      subscription.school_year_id = school_year_subscription.id
      subscription.s_type = souscription_type
      if statut_etu == "ETUDIANT"
        subscription.statut_etu = :etudiant
      elsif statut_etu == "PRO"
        subscription.statut_etu = :contrat_pro
      elsif statut_etu == "APPRENTISSAGE"
        subscription.statut_etu = :apprentissage
      else
        return false
      end
      subscription.reduction = 0
      subscription.modalite = modalite
      subscription.etudiant_confirm_reinscription = confirm_reinscription
      subscription.payment_mode_inscription = :prelevement
      subscription.payment_mode_scolarite = :prelevement
      if subscription.save
        if send_credentials
          password = Devise.friendly_token.first(10)
          self.user.update(password: password)
          UserMailer.send_credentials(self.user, password).deliver_later
        end
        return true
      else
        return false
      end
    rescue
      return false
    end
  end

  def etu_nom_prenom
    return self.etu_nom.upcase + " " + self.etu_prenom.upcase
  end

  def rf_nom_prenom
    return (self.nom.upcase rescue "") + " " + (self.prenom.upcase rescue "")
  end

  def self.to_csv_export
    headers = ["CODE TIERS", "STATUT", "NOM ETU", "PRENOM ETU", "EMAIL ETU", "ADRESSE ETU", "VILLE ETU", "CP VILLE", "TEL PORT ETU", "NOM RF", "PRENOM RF", "ADRESSE RF", "VILLE RF", "CP RF", "EMAIL RF", "TEL PORT RF", "CAMPUS", "FORMATION", "ORIGINE", "MODE INSCRIPTION", "MODE SCOLARITE", "MODALITE SCOLARITE", "STATUT"]
    CSV.generate(write_headers: true, headers: headers, converters: :all, :col_sep => ";") do |csv|
      all.each do |data|
        if data.user_financier_subscriptions.any?
          statut = data.user_financier_subscriptions.last.statut_etu.upcase
        else
          statut = ""
        end
        csv << [data.code_tiers, statut, I18n.transliterate(data.etu_nom), I18n.transliterate(data.etu_prenom), data.etu_email, data.etu_adresse, data.etu_ville, data.etu_code_postal, data.etu_tel, I18n.transliterate(data.nom), I18n.transliterate(data.prenom), data.adresse, data.ville, data.code_postal, data.user.email, data.tel, data.centre.ville, (data.user_financier_subscriptions.last.formation_annee.formation.nom rescue ""), (data.user_financier_subscriptions.last.s_type.humanize rescue ""), (data.user_financier_subscriptions.last.payment_mode_inscription.humanize rescue ""), (data.user_financier_subscriptions.last.payment_mode_scolarite.humanize rescue ""), (data.user_financier_subscriptions.last.modalite rescue ""), (data.user_financier_subscriptions.last.statut_humanized.humanize rescue "")]
      end
    end
  end

  def self.to_csv_export_reinscription
    headers = ["NOM ETU", "PRENOM ETU", "EMAIL ETU", "NOM RF", "PRENOM RF", "EMAIL RF", "CAMPUS", "FORMATION", "LIEN FORMULAIRE"]
    CSV.generate(write_headers: true, headers: headers, converters: :all, :col_sep => ";") do |csv|
      all.each do |data|
        if data.user_financier_subscriptions.any? && data.user_financier_subscriptions.last.waiting_user?
          url = Rails.application.routes.url_helpers.user_reinscription_url(data.user.uuid)
          csv << [I18n.transliterate(data.etu_nom), I18n.transliterate(data.etu_prenom), data.etu_email, I18n.transliterate(data.nom), I18n.transliterate(data.prenom), data.user.email, data.centre.ville, (data.user_financier_subscriptions.last.formation_annee.formation.nom rescue ""), url]
        end
      end
    end
  end

  def self.to_csv_codes_tiers
    headers = ["CODE TIERS", "LIBELLE", "ABREGE", "COMPTE COLLECTIF", "UID", "STATUT", "SITE", "NOM RF", "ADRESSE RF", "COMPLEMENT ADRESSE RF", "VILLE RF", "CP RF", "EMAIL RF", "TEL PORT RF"]
    CSV.generate(converters: :all, :col_sep => ";") do |csv|
      all.each do |data|
        compte_collectif = "41111111"
        uid = ""
        statut = ""
        if data.user_financier_subscriptions.last
          statut = data.user_financier_subscriptions.last.s_type.humanize
          compte_collectif = data.user_financier_subscriptions.last.formation_annee.formation.centre.centre_customer_accounts.find_by(school_year_id: data.user_financier_subscriptions.last.school_year_id).compte_client_sage rescue nil
        else
          statut = ""
        end
        csv << [data.code_tiers, I18n.transliterate(data.etu_nom_prenom), I18n.transliterate(data.etu_nom_prenom.truncate(17, omission: "")), compte_collectif, uid, statut, data.centre.ville, I18n.transliterate(data.rf_nom_prenom), (data.adresse.squish rescue nil), (data.adresse_2.squish rescue nil), data.code_postal, data.ville, data.user.email, data.tel]
      end
    end
  end

  def self.to_csv_without_mandate
    headers = ["CAMPUS", "ETUDIANT", "FORMATION", "MODALITE", "RF", "EMAIL RF", "TEL PORT RF", "ORIGINE"]
    CSV.generate(write_headers: true, headers: headers, converters: :all, :col_sep => ";") do |csv|
      all.each do |data|
        if data.user_financier_subscriptions.any? && data.user_financier_rib.iban.nil?
          var = data.user_financier_subscriptions.where(statut: [:waiting_user, :waiting_compta, :active, :partial_inscription, :partial_techniques]).last.user_financier_subscription_instalments.where(v_mode: :prelevement) rescue nil
          if !var.nil? && var.any?
            subscription = data.user_financier_subscriptions.where(statut: [:waiting_user, :waiting_compta, :active, :partial_inscription, :partial_techniques]).last
            csv << [data.centre.ville, I18n.transliterate(data.etu_nom_prenom), subscription.formation_annee.formation.nom, subscription.modalite, I18n.transliterate(data.rf_nom_prenom), data.user.email, data.tel, data.user_financier_subscriptions.last.s_type.humanize]
          end
        end
      end
    end
  end

  def self.to_csv_ibans
    headers = ["CODE TIERS", "BIC", "IBAN", "RUM", "LIBELLE TIERS", "DATE DE SIGNATURE"]
    CSV.generate(converters: :all, :col_sep => ";") do |csv|
      all.includes(:user_financier_rib).each do |data|
        if !data.user_financier_rib.iban.nil?
          bic = data.user_financier_rib.bic
          iban = data.user_financier_rib.iban.gsub(" ", "")
          rum = data.user_financier_rib.rum
          date = data.created_at.strftime("%d/%m/%Y")
          csv << [data.code_tiers, bic, iban, rum, I18n.transliterate(data.etu_nom_prenom), date]
        end
      end
    end
  end

  def transfer(new_centre)
    centre = Centre.find(new_centre) rescue nil
    if centre
      self.user_financier_subscriptions.where(statut: [:waiting_user, :waiting_admin, :waiting_compta, :active, :partial_inscription, :partial_techniques]).each do |sub|
        formation = sub.formation_annee.formation
        new_formation = Formation.where(centre_id: centre.id, nom: formation.nom).first rescue nil
        if new_formation
          new_formation_annee = new_formation.formation_annees.where(school_year_id: sub.formation_annee.school_year_id).first rescue nil
          if new_formation_annee
            if !sub.transfer_campus_formation(new_formation_annee)
              return false
            end
          else
            return false
          end
        else
          return false
        end
      end
    else
      return false
    end

    self.update(centre_id: centre.id)
    return true
  end

  def get_params_login
    return "#{self.centre.school_program.school.nom.upcase}#{self.centre.school_program.school.school_programs.count > 1 ? "_" + self.centre.school_program.nom : ""}"
  end
end
