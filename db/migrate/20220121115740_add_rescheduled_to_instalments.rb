class AddRescheduledToInstalments < ActiveRecord::Migration[6.1]
  def change
    add_column :user_financier_subscription_instalments, :rescheduled, :boolean, default: false, after: :refunded
  end
end
