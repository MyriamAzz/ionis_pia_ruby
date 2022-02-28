class RemoveColTypeToFormations < ActiveRecord::Migration[6.0]
  def change
    remove_column :formations, :f_type
  end
end
