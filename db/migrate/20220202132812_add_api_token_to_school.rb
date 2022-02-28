class AddAPITokenToSchool < ActiveRecord::Migration[6.1]
  def change
    add_column :schools, :grape_api_token, :string, after: :couleur
  end
end
