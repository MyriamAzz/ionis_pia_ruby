class AddGocardlessIdsToUserFinancierAndRibs < ActiveRecord::Migration[6.0]
  def change
    add_column :user_financiers, :gocardless_customer_id, :string, after: :etu_email
    add_column :user_financier_ribs, :gocardless_mandate_id, :string, after: :bic
  end
end
