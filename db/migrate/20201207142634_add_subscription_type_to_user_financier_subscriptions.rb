class AddSubscriptionTypeToUserFinancierSubscriptions < ActiveRecord::Migration[6.0]
  def change
    add_column :user_financier_subscriptions, :s_type, :integer, after: :school_year_id
  end
end
