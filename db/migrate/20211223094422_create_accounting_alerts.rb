class CreateAccountingAlerts < ActiveRecord::Migration[6.1]
  def change
    create_table :accounting_alerts do |t|
      t.references :centre
      t.references :user
      t.references :user_financier_subscription
      t.integer :atype
      t.string :comment
      t.float :amount
      t.boolean :done, default: false
      t.datetime :done_at
      t.integer :done_by
      t.string :done_answer
      t.timestamps
    end
  end
end
