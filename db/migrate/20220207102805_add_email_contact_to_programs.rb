class AddEmailContactToPrograms < ActiveRecord::Migration[6.1]
  def change
    add_column :school_programs, :email_contact, :string, after: :email_from
  end
end
