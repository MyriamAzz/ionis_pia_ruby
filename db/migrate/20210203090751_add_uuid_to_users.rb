class AddUuidToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :uuid, :string, limit: 36, after: :id
  end
end
