class AddImportToUserFinancier < ActiveRecord::Migration[6.1]
  def change
    add_column :user_financiers, :imported, :boolean, default: false, after: :centre_id
  end
end
