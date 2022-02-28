class ChangeFormationAnnee < ActiveRecord::Migration[6.0]
  def change
    remove_column :formation_annees, :f_modalite
    add_column :formation_annees, :frais_inscription, :float, after: :f_annee
    add_column :formation_annees, :frais_technique, :float, after: :frais_inscription
    add_column :formation_annees, :frais_bde, :float, after: :frais_technique
    add_column :formation_annees, :modalite_1, :float, after: :frais_bde
    add_column :formation_annees, :modalite_3, :float, after: :modalite_1
    add_column :formation_annees, :modalite_10, :float, after: :modalite_3
  end
end
