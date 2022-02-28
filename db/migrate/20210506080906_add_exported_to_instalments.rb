class AddExportedToInstalments < ActiveRecord::Migration[6.0]
  def change
    add_column :user_financier_subscription_instalments, :exported, :boolean, default: false, after: :gocardless_id
  end
end
