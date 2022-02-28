class AddCreditToInstalments < ActiveRecord::Migration[6.1]
  def change
    add_column :user_financier_subscription_instalments, :refunded, :boolean, default: false, after: :formation_changed
    add_column :user_financier_subscription_instalments, :refunded_at, :datetime, after: :refunded
    add_column :user_financier_subscription_instalments, :need_accounted, :boolean, default: true, after: :formation_changed
  end
end
