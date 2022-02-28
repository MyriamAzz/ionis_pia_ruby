class AddDatesToUserFinancierSubscriptions < ActiveRecord::Migration[6.0]
  def change
    add_column :user_financier_subscriptions, :frais_scolarite_done_date, :datetime, after: :frais_scolarite_done
    add_column :user_financier_subscriptions, :frais_techniques_done_date, :datetime, after: :frais_scolarite_done
    add_column :user_financier_subscriptions, :frais_inscription_done_date, :datetime, after: :frais_scolarite_done
  end
end
