class AddSiretToCentres < ActiveRecord::Migration[6.0]
  def change
    add_column :centres, :siret, :string, after: :tel
  end
end
