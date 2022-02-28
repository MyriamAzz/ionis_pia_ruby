class AddCentreToUserAdmins < ActiveRecord::Migration[6.1]
  def change
    add_column :user_admins, :centre_id, :integer, after: :user_id
  end
end
