class AddStudentInfo1ToUserFinanciers < ActiveRecord::Migration[6.0]
  def change
    add_column :user_financiers, :tel, :string, after: :pays
    add_column :user_financier_ribs, :rum, :string, after: :bic
  end
end
