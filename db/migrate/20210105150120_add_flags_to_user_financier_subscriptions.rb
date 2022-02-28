class AddFlagsToUserFinancierSubscriptions < ActiveRecord::Migration[6.0]
  def change
    add_column :user_financier_subscriptions, :frais_scolarite_done, :boolean, default: false, after: :redoublant
    add_column :user_financier_subscriptions, :frais_techniques_done, :boolean, default: false, after: :redoublant
    add_column :user_financier_subscriptions, :frais_inscription_done, :boolean, default: false, after: :redoublant
  end
end
