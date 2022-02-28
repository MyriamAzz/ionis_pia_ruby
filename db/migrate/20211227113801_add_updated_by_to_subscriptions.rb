class AddUpdatedByToSubscriptions < ActiveRecord::Migration[6.1]
  def change
    add_column :user_financier_subscriptions, :updated_by, :integer, after: :etudiant_reinscription_done_date
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
