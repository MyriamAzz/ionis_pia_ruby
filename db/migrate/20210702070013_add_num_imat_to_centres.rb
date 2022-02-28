class AddNumImatToCentres < ActiveRecord::Migration[6.0]
  def change
    add_column :centres, :num_immatriculation, :string, after: :siret
  end
end
