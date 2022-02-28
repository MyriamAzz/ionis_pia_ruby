class CreateUserFinancierSubscriptionInstalments < ActiveRecord::Migration[6.0]
  def change
    create_table :user_financier_subscription_instalments do |t|
      t.integer :user_financier_subscripion_id
      t.integer :statut
      t.date :echeance
      t.float :montant
      t.timestamps
    end
  end
end
