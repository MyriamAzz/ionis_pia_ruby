class CreateSchools < ActiveRecord::Migration[6.1]
  def change
    create_table :schools do |t|
      t.string :nom
      t.string :couleur
      t.timestamps
    end
  end
end
