class Formation < ApplicationRecord
  belongs_to :centre

  validates :nom, :centre_id, presence: true
  validates_uniqueness_of :nom, case_sensitive: false, scope: [:centre_id]

  before_save :format_formation
  before_destroy :process_check_destroy

  has_many :formation_annees, dependent: :destroy
  has_many :user_financier_subscriptions, through: :formation_annees
  has_many :user_financier_subscription_instalments, through: :user_financier_subscriptions

  accepts_nested_attributes_for :formation_annees, reject_if: :all_blank, allow_destroy: true

  scope :filter_actived, -> { where(archived: false) }
  scope :filter_archived, -> { where(archived: true) }

  def format_formation
    self.nom = self.nom.titleize
  end

  def process_check_destroy
    if self.user_financier_subscriptions.any?
      throw(:abort)
    end
  end
end
