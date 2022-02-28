class CreateCentres < ActiveRecord::Migration[6.0]
  def change
    create_table :centres do |t|
      t.string :nom
      t.string :adresse
      t.string :cp
      t.string :ville
      t.string :tel
      t.timestamps
    end
  end
end
