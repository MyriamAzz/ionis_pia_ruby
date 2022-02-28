class AddAdresse2ToUserFinanciers < ActiveRecord::Migration[6.0]
  def change
    add_column :user_financiers, :adresse_2, :string, after: :adresse
  end
end
