class AddUserFinancierSubscriptionInstalmentsToLogSales < ActiveRecord::Migration[6.0]
  def change
    add_column :log_sales, :user_financier_subscription_instalment_id, :integer, after: :user_financier_subscription_id
  end
end
