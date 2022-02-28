class AddAcronymeToCentre < ActiveRecord::Migration[6.0]
  def change
    add_column :centres, :acronyme, :string, after: :nom
  end
end
