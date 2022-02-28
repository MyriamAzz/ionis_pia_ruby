class ChangeFloatToDecimal < ActiveRecord::Migration[6.1]
  def change
    change_column :payouts, :gc_amount, :decimal, precision: 10, scale: 2
    change_column :log_sales, :credit, :decimal, precision: 10, scale: 2
    change_column :log_sales, :debit, :decimal, precision: 10, scale: 2
  end
end
