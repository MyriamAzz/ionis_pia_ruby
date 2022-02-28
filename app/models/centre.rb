class Centre < ApplicationRecord
  validates :nom, presence: true
  validates_uniqueness_of :nom, case_sensitive: false, scope: [:school_program_id]

  belongs_to :school_program

  has_many :centre_customer_accounts, dependent: :destroy
  accepts_nested_attributes_for :centre_customer_accounts, reject_if: :all_blank, allow_destroy: true

  has_many :user_financiers, dependent: :destroy
  has_many :formations, -> { order(:nom) }, dependent: :destroy
  has_many :formation_annees, through: :formations
  has_many :user_financier_subscriptions, through: :formation_annees
  has_many :user_financier_subscription_instalments, through: :user_financier_subscriptions

  has_many :user_financiers, dependent: :destroy
  has_many :user_financier_subscriptions, through: :user_financiers
  has_many :user_financier_subscription_instalments, through: :user_financier_subscriptions

  has_many :user_admin_centres, dependent: :destroy_async
  has_many :users, through: :user_admin_centres

  has_many :accounting_alerts, dependent: :destroy_async

  has_many :payouts, dependent: :destroy_async

  has_one_attached :bank_details, service: :s3

  scope :actived, -> { where("") }

  before_save :format_fields

  def format_fields
    # self.nom = self.nom.titleize
    self.adresse = self.adresse.capitalize rescue nil
    self.ville = self.ville.titleize rescue nil
    self.acronyme = self.acronyme.upcase rescue nil
  end

  def select_nom
    return "#{self.nom} - #{self.school_program.nom} - #{self.school_program.school.nom}"
  end
end
