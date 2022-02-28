class AddCompteClientAffaireToFormationAndCentre < ActiveRecord::Migration[6.0]
  def change
    add_column :centres, :compte_client_sage, :integer, after: :code_sage
    add_column :formations, :compte_client_sage, :integer, after: :code
  end
end
