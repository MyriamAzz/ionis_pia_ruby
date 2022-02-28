class AddGocardlessGeneralToSchoolPrograms < ActiveRecord::Migration[6.1]
  def change
    add_column :school_programs, :gocardless_general, :boolean, default: false, after: :footer_2
  end
end
