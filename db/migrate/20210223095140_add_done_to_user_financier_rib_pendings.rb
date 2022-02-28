class AddDoneToUserFinancierRibPendings < ActiveRecord::Migration[6.0]
  def change
    add_column :user_financier_rib_pendings, :processed, :boolean, default: false, after: :gocardless_payer_authorisation_id
  end
end
