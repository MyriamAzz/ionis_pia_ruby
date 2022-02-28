class CreatePaymentPlans < ActiveRecord::Migration[6.1]
  def change
    create_table :payment_plans do |t|
      t.references :school_program
      t.integer :plan
      t.timestamps
    end
  end
end
