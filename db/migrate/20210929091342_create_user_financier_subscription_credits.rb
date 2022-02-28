class CreateUserFinancierSubscriptionCredits < ActiveRecord::Migration[6.0]
  def change
    create_table :user_financier_subscription_credits do |t|
      t.references :user_financier_subscription, index: { name: :index_subscription_credits_on_subscription_id }
      t.references :user_financier_subscription_instalment, index: { name: :index_subscription_credits_on_instalment_id }
      t.integer :creator_id
      t.string :facture_ref
      t.date :echeance
      t.float :montant
      t.string :code_export
      t.string :libelle
      t.timestamps
    end
  end
end
