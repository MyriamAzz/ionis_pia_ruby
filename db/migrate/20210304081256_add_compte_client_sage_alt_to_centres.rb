class AddCompteClientSageAltToCentres < ActiveRecord::Migration[6.0]
  def change
    add_column :centres, :compte_client_sage_alt, :int, after: :compte_client_sage
  end
end
