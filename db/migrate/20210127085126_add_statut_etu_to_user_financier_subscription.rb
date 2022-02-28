class AddStatutEtuToUserFinancierSubscription < ActiveRecord::Migration[6.0]
  def change
    add_column :user_financier_subscriptions, :statut_etu, :integer, after: :redoublant
  end
end
