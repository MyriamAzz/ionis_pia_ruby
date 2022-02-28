class AddCustomToInstalments < ActiveRecord::Migration[6.1]
  def change
    add_column :user_financier_subscription_instalments, :custom_line, :boolean, default: false, after: :need_accounted
  end
end
