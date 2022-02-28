class AddFraisInscriptionJoursToSchoolYear < ActiveRecord::Migration[6.1]
  def change
    add_column :school_years, :frais_inscription_jours, :integer, after: :fin
    add_column :school_years, :frais_techniques_date, :date, after: :frais_inscription_jours
  end
end
