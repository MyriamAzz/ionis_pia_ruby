class AddExportedToLogSales < ActiveRecord::Migration[6.0]
  def change
    add_column :log_sales, :exported, :boolean, default: false, after: :modalite
  end
end
