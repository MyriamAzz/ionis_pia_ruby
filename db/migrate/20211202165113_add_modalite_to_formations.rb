class AddModaliteToFormations < ActiveRecord::Migration[6.1]
  def change
    add_column :formation_annees, :modalite_2, :float, after: :modalite_1
    add_column :formation_annees, :modalite_4, :float, after: :modalite_3
    add_column :formation_annees, :modalite_5, :float, after: :modalite_4
    add_column :formation_annees, :modalite_6, :float, after: :modalite_5
    add_column :formation_annees, :modalite_7, :float, after: :modalite_6
    add_column :formation_annees, :modalite_8, :float, after: :modalite_7
    add_column :formation_annees, :modalite_9, :float, after: :modalite_8
  end
end
