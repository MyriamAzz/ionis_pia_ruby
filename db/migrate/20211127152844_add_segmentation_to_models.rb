class AddSegmentationToModels < ActiveRecord::Migration[6.1]
  def change
    add_column :centres, :school_program_id, :integer, after: :id
    add_column :school_years, :school_program_id, :integer, after: :id
  end
end
