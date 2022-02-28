class CreateSchoolYears < ActiveRecord::Migration[6.0]
  def change
    create_table :school_years do |t|
      t.string :nom
      t.date :debut
      t.date :fin
      t.timestamps
    end
  end
end
