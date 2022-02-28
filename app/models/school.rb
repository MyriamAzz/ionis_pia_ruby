class School < ApplicationRecord
  validates_uniqueness_of :nom, case_sensitive: true

  has_many :school_programs
  has_many :centres, through: :school_programs
  has_many :user_financiers, through: :centres

  before_save :process_before_save

  def process_before_save
    if self.grape_api_token.blank?
      self.grape_api_token = SecureRandom.base64(60)
    end
  end
end
