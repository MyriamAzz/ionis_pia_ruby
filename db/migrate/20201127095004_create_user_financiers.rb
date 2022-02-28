class CreateUserFinanciers < ActiveRecord::Migration[6.0]
  def change
    create_table :user_financiers do |t|
      t.references :user
      t.references :centre
      t.string :nom
      t.string :prenom
      t.string :etu_nom
      t.string :etu_prenom
      t.string :etu_email
      t.timestamps
    end
  end
end
