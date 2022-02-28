class SchoolProgram < ApplicationRecord
  validates_uniqueness_of :nom, case_sensitive: true, scope: [:school_id]
  belongs_to :school

  has_many :centres, dependent: :destroy_async
  has_many :school_years, -> { order(nom: :desc) }, dependent: :destroy_async
  has_many :payment_plans, -> { order(:plan) }, dependent: :destroy_async
  has_many :users, -> { distinct }, through: :centres, source: :users
  has_many :formations, -> { distinct }, through: :centres, source: :formations

  has_many :payouts, dependent: :destroy_async

  has_one_attached :logo
  has_one_attached :logo_color
  has_one_attached :bank_details, service: :s3
  has_one_attached :resp_signature, service: :s3

  def logo_default_path
    if self.logo.attached?
      return self.logo
    else
      return ""
    end
  end

  def select_nom
    return self.nom + " (" + self.school.nom + ")"
  end

  def label_school_program
    return "#{self.school.nom} - #{self.nom}"
  end

  def get_current_school_year
    a = self.school_years.where("debut <= ? AND fin >= ?", Date.today, Date.today).first rescue nil
    if a
      return a
    else
      return self.school_years.last
    end
  end
end
