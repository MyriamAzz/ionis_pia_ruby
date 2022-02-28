class SchoolYear < ApplicationRecord
  validates :nom, :debut, :fin, presence: true
  validates_uniqueness_of :nom, case_sensitive: false, scope: [:school_program_id]

  belongs_to :school_program

  scope :actual, -> { where("debut < ? AND fin > ?", Date.today, Date.today) }
  scope :active, -> { order(nom: :desc) }

  before_destroy :process_check_destroy

  has_many :formation_annees, dependent: :destroy
  has_many :formations, through: :formation_annees
  has_many :payment_calendars, dependent: :destroy

  def process_check_destroy
    if self.formation_annees.any?
      throw(:abort)
    end
  end
end
