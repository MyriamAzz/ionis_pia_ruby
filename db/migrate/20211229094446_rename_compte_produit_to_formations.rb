class RenameCompteProduitToFormations < ActiveRecord::Migration[6.1]
  def change
    remove_column :formations, :compte_produit_sage
    rename_column :formations, :compte_client_sage, :compte_produit_sage
  end
end
