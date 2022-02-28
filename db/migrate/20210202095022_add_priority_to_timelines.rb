class AddPriorityToTimelines < ActiveRecord::Migration[6.0]
  def change
    add_column :user_financier_timelines, :priority, :integer, after: :comment
  end
end
