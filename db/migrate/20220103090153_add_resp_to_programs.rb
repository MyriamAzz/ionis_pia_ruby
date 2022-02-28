class AddRespToPrograms < ActiveRecord::Migration[6.1]
  def change
    add_column :school_programs, :resp_fonction, :string, after: :ville
    add_column :school_programs, :resp_prenom, :string, after: :ville
    add_column :school_programs, :resp_nom, :string, after: :ville
    add_column :school_programs, :footer_2, :string, after: :ics
    add_column :school_programs, :footer_1, :string, after: :ics
  end
end
