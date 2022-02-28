class AddCompteAttenteToCentres < ActiveRecord::Migration[6.1]
  def change
    add_column :centres, :compte_attente_sage, :integer, after: :compte_client_sage
    add_column :centres, :compte_banque_sage, :integer, after: :compte_client_sage

    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
