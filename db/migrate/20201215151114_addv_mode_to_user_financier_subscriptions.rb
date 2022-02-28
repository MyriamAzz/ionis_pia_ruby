class AddvModeToUserFinancierSubscriptions < ActiveRecord::Migration[6.0]
  def change
    add_column :user_financier_subscription_instalments, :v_mode, :integer, after: :v_type
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
