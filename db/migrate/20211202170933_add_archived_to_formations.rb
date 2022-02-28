class AddArchivedToFormations < ActiveRecord::Migration[6.1]
  def change
    add_column :formations, :archived, :boolean, default: false, after: :compte_produit_sage
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
