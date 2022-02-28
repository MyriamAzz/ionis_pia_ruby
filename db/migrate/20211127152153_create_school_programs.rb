class CreateSchoolPrograms < ActiveRecord::Migration[6.1]
  def change
    create_table :school_programs do |t|
      t.references :school
      t.string :nom
      t.timestamps
    end
  end
end
