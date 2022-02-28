class AddGocardlessTokenToCentres < ActiveRecord::Migration[6.1]
  def change
    add_column :centres, :gocardless_endpoint_secret, :string, after: :compte_client_sage_alt
    add_column :centres, :gocardless_token, :string, after: :compte_client_sage_alt
  end
end
