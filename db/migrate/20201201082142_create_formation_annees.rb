class CreateFormationAnnees < ActiveRecord::Migration[6.0]
  def change
    create_table :formation_annees do |t|
      t.references :formation
      t.references :school_year
      t.integer :f_annee
      t.integer :f_modalite
      t.timestamps
    end
  end
end
