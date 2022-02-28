class CreateUserAdmins < ActiveRecord::Migration[6.0]
  def change
    create_table :user_admins do |t|
      t.references :user
      t.string :nom
      t.string :prenom
      t.timestamps
    end
  end
end
