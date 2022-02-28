class AddCodeTiersToUserFinanciers < ActiveRecord::Migration[6.0]
  def change
    add_column :user_financiers, :code_tiers, :string, after: :etu_id_sf
  end
end
