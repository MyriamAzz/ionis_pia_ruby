class AddStatusToAccountingAlerts < ActiveRecord::Migration[6.1]
  def change
    remove_column :accounting_alerts, :done
    remove_column :accounting_alerts, :done_at
    remove_column :accounting_alerts, :done_by_id
    rename_column :accounting_alerts, :done_answer, :comment_1
    add_column :accounting_alerts, :handled_by_id, :integer, after: :amount
    add_column :accounting_alerts, :status, :integer, after: :atype, default: 0
  end
end
