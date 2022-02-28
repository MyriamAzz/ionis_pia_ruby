class AddNewFormationToInstalments < ActiveRecord::Migration[6.0]
  def change
    add_column :user_financier_subscription_instalments, :formation_changed, :boolean, default: false, after: :gocardless_id
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
