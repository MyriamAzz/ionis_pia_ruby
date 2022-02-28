class AddGocardlessIdToInstalments < ActiveRecord::Migration[6.0]
  def change
    add_column :user_financier_subscription_instalments, :gocardless_id, :string, after: :v_mode
  end
end
