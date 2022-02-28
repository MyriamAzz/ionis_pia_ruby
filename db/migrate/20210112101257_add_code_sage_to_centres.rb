class AddCodeSageToCentres < ActiveRecord::Migration[6.0]
  def change
    add_column :centres, :code_sage, :string, after: :tel
  end
end
