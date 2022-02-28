class CreateCentreCustomerAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :centre_customer_accounts do |t|
      t.references :centre
      t.references :school_year
      t.string :compte_client_sage
      t.timestamps
    end
  end
end
