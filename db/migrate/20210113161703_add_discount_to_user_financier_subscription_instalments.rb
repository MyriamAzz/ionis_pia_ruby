class AddDiscountToUserFinancierSubscriptionInstalments < ActiveRecord::Migration[6.0]
  def change
    add_column :user_financier_subscription_instalments, :montant_initial, :float, after: :montant
  end
end
