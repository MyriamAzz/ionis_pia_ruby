class AddCanForceTurnoverToInstalments < ActiveRecord::Migration[6.1]
  def change
    add_column :user_financier_subscription_instalments, :can_force_turnover, :boolean, default: false, after: :custom_line
  end
end
