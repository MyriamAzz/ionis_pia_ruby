class AddArchivedToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :archived, :boolean, default: :false, after: :role
  end
end
