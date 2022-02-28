class ChangeColToLogSales < ActiveRecord::Migration[6.0]
  def change
    change_column :log_sales, :date_echeance, :date
  end
end
