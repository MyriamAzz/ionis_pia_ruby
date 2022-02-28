class AddMonthSchoolStartToSubscriptions < ActiveRecord::Migration[6.1]
  def change
    add_column :user_financier_subscriptions, :month_start, :string, after: :school_year_id
  end
end
