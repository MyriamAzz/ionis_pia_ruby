class AddSchoolYearIdToUserFinancierTimelines < ActiveRecord::Migration[6.0]
  def change
    add_column :user_financier_timelines, :school_year_id, :integer, after: :user_id
  end
end
