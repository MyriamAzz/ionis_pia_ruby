class AddEmailFromToPrograms < ActiveRecord::Migration[6.1]
  def change
    add_column :school_programs, :email_from, :string, after: :nom
  end
end
