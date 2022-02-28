class AddCompteProduitToFormations < ActiveRecord::Migration[6.1]
  def change
    add_column :formations, :compte_produit_sage, :string, after: :compte_client_sage
  end
end
