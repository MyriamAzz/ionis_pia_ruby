class CreateUserFinancierRibs < ActiveRecord::Migration[6.0]
  def change
    create_table :user_financier_ribs do |t|
      t.references :user_financier
      t.string :iban
      t.string :bic
      t.timestamps
    end
  end
end
