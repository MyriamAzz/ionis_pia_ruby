class CreatePaymentCalendars < ActiveRecord::Migration[6.1]
  def change
    create_table :payment_calendars do |t|
      t.references :school_year
      t.integer :plan
      t.integer :plan_order
      t.date :plan_date
      t.timestamps
    end
  end
end
