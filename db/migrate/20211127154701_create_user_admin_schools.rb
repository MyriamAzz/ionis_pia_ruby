class CreateUserAdminSchools < ActiveRecord::Migration[6.1]
  def change
    create_table :user_admin_schools do |t|
      t.references :user
      t.references :school
      t.timestamps
    end
  end
end
