class NumFactureToCentreCustomerAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :centre_customer_accounts, :num_facture, :integer, default: 0, after: :compte_client_sage
  end
end
