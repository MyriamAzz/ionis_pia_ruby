class AddDontRelaunchCommentToUSerFiancier < ActiveRecord::Migration[6.1]
  def change
    add_column :user_financiers, :dont_relaunch_comment, :text, after: :dont_relaunch
  end
end
