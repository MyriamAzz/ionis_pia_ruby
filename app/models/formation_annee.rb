class FormationAnnee < ApplicationRecord
  belongs_to :formation
  belongs_to :school_year

  validates_uniqueness_of :formation_id, scope: [:school_year_id]

  has_many :user_financier_subscriptions

  # enum f_annee: [:année_1, :année_2, :année_3, :année_4, :année_5]
end
