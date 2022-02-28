class AddRedoublantToUserFinancierSubscriptions < ActiveRecord::Migration[6.0]
  def change
    add_column :user_financier_subscriptions, :redoublant, :boolean, default: false, after: :statut
  end
end
