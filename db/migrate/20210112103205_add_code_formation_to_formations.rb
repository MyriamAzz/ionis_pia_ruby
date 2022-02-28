class AddCodeFormationToFormations < ActiveRecord::Migration[6.0]
  def change
    add_column :formations, :code, :string, after: :f_type
  end
end
