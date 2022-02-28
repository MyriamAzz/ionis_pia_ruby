class AddAccountGoCardlessToRib < ActiveRecord::Migration[6.0]
  def change
    add_column :user_financier_ribs, :gocardless_account_id, :string, after: :bic
  end
end
