class AddStudentInfoToUserFinanciers < ActiveRecord::Migration[6.0]
  def change
    add_column :user_financiers, :etu_id_sf, :string, after: :etu_email
    add_column :user_financiers, :etu_famille_ionis_nom, :string, after: :etu_email
    add_column :user_financiers, :etu_famille_ionis_prenom, :string, after: :etu_email
    add_column :user_financiers, :etu_famille_ionis, :string, after: :etu_email
    add_column :user_financiers, :etu_tel, :string, after: :etu_email
    add_column :user_financiers, :etu_pays, :string, after: :etu_email
    add_column :user_financiers, :etu_code_postal, :string, after: :etu_email
    add_column :user_financiers, :etu_ville, :string, after: :etu_email
    add_column :user_financiers, :etu_adresse, :string, after: :etu_email
  end
end
