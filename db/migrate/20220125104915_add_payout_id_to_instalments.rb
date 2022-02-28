class AddPayoutIdToInstalments < ActiveRecord::Migration[6.1]
  def change
    add_column :user_financier_subscription_instalments, :payout_id, :integer, after: :user_financier_subscription_id
  end
end
