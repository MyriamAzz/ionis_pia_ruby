class AddReductionTypeToSubscriptions < ActiveRecord::Migration[6.0]
  def change
    add_column :user_financier_subscriptions, :reduction_type, :integer, after: :reduction
  end
end
