class AddTypeFormationToFormation < ActiveRecord::Migration[6.0]
  def change
    remove_column :formations, :schoolyear_id
    add_column :formations, :f_type, :integer, after: :nom
  end
end
