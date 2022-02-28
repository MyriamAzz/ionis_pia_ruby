class CreateUserAdminCentres < ActiveRecord::Migration[6.0]
  def change
    create_table :user_admin_centres do |t|
      t.references :user
      t.references :centre
      t.timestamps
    end
  end
end
