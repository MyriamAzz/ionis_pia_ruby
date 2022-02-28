class CreateFormations < ActiveRecord::Migration[6.0]
  def change
    create_table :formations do |t|
      t.references :schoolyear
      t.references :centre
      t.string :nom
      t.timestamps
    end
  end
end
