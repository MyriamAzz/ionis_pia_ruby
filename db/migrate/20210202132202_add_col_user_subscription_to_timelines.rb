class AddColUserSubscriptionToTimelines < ActiveRecord::Migration[6.0]
  def change
    add_column :user_financier_timelines, :user_financier_subscription_id, :integer, after: :user_financier_id
  end
end
