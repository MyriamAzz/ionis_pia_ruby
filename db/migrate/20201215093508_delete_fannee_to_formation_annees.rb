class DeleteFanneeToFormationAnnees < ActiveRecord::Migration[6.0]
  def change
    remove_column :formation_annees, :f_annee
  end
end
