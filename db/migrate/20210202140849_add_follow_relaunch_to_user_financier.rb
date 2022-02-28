class AddFollowRelaunchToUserFinancier < ActiveRecord::Migration[6.0]
  def change
    add_column :user_financiers, :follow, :boolean, default: :false, after: :gocardless_customer_id
    add_column :user_financiers, :relaunch, :boolean, default: :false, after: :gocardless_customer_id
  end
end
