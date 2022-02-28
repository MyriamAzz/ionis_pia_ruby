class ChangeColEventStatusToInstalmentsEvents < ActiveRecord::Migration[6.0]
  def change
    change_column :user_financier_subscription_instalment_events, :gocardless_status, :integer
  end
end
