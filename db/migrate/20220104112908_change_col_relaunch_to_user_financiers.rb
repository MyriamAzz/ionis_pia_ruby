class ChangeColRelaunchToUserFinanciers < ActiveRecord::Migration[6.1]
  def change
    rename_column :user_financiers, :relaunch, :dont_relaunch
  end
end
