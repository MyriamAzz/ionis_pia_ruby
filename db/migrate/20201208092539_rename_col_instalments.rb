class RenameColInstalments < ActiveRecord::Migration[6.0]
  def change
    rename_column :user_financier_subscription_instalments, :user_financier_subscripion_id, :user_financier_subscription_id
    #Ex:- change_column("admin_users", "email", :string, :limit =>25)
  end
end
