class CreateUserFinancierSubscriptionInstalmentEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :user_financier_subscription_instalment_events do |t|
      t.integer :user_financier_subscription_instalment_id
      t.string :gocardless_id
      t.string :gocardless_status
      t.string :gocardless_cause
      t.string :gocardless_description
      t.timestamps
    end
  end
end
