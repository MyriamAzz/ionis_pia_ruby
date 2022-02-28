class AddAdresseToUserFinanciers < ActiveRecord::Migration[6.0]
  def change
    add_column :user_financiers, :adresse, :string, after: :prenom
    add_column :user_financiers, :code_postal, :string, after: :adresse
    add_column :user_financiers, :ville, :string, after: :code_postal
    add_column :user_financiers, :pays, :string, after: :ville
  end
end
