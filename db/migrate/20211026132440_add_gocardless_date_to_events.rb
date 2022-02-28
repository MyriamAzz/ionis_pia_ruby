class AddGocardlessDateToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :user_financier_subscription_instalment_events, :gocardless_date, :datetime, precision: 3, after: :gocardless_description
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
