class CreateUserFinancierTimelines < ActiveRecord::Migration[6.0]
  def change
    create_table :user_financier_timelines do |t|
      t.references :user
      t.references :formation_annee
      t.integer :statut
      t.timestamps
    end
  end
end
