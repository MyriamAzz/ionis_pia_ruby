class CreateUserFinancierMandates < ActiveRecord::Migration[6.0]
  def change
    create_table :user_financier_mandates do |t|
      t.references :user_financier
      t.string :rum
      t.string :nom
      t.string :prenom
      t.string :email
      t.string :adresse
      t.string :cp
      t.string :ville
      t.string :pays
      t.string :iban
      t.string :bic
      t.string :adresse_ip
      t.boolean :actif, default: false
      t.timestamps
    end
  end
end
