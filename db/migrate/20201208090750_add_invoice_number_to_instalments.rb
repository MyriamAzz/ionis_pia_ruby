class AddInvoiceNumberToInstalments < ActiveRecord::Migration[6.0]
  def change
    add_column :user_financier_subscription_instalments, :v_type, :integer, after: :montant
    add_column :user_financier_subscription_instalments, :facture, :string, after: :montant
  end
end
