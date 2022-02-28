class AddAddressAndIcsToPrograms < ActiveRecord::Migration[6.1]
  def change
    add_column :school_programs, :ville, :string, after: :nom
    add_column :school_programs, :cp, :string, after: :nom
    add_column :school_programs, :adresse, :string, after: :nom
    add_column :school_programs, :ics, :string, after: :email_from
    add_column :centres, :ics, :string, after: :num_immatriculation
  end
end
