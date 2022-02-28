class ChangeDoneByToAccountingAlerts < ActiveRecord::Migration[6.1]
  def change
    rename_column :accounting_alerts, :done_by, :done_by_id
  end
end
