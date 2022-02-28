class CreateUserAdminSchoolPrograms < ActiveRecord::Migration[6.1]
  def change
    create_table :user_admin_school_programs do |t|
      t.references :user
      t.references :school_program
      t.timestamps
    end
  end
end
