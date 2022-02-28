class CreateUserFinancierRibEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :user_financier_rib_events do |t|
      t.integer :user_financier_id
      t.string :gocardless_id
      t.string :gocardless_mandate_id
      t.integer :gocardless_status
      t.string :gocardless_cause
      t.string :gocardless_reason_code
      t.string :gocardless_description
      t.timestamps
    end
  end
end
