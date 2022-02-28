class AddExportedAtToLogSales < ActiveRecord::Migration[6.0]
  def change
    add_column :log_sales, :exported_at, :datetime, after: :exported
    add_column :log_sales, :exported_by, :integer, after: :exported_at
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
