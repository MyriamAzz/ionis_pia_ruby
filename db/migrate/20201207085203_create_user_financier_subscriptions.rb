class CreateUserFinancierSubscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :user_financier_subscriptions do |t|
      t.references :user_financier
      t.references :formation_annee
      t.references :school_year
      t.integer :modalite
      t.integer :reduction
      t.integer :statut
      t.timestamps
    end
  end
end
