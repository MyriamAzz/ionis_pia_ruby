class AddDoneToInstalmentEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :user_financier_subscription_instalment_events, :done, :boolean, default: false, after: :gocardless_description
  end
end
