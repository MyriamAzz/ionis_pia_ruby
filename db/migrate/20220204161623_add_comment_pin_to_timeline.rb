class AddCommentPinToTimeline < ActiveRecord::Migration[6.1]
  def change
    add_column :user_financier_timelines, :comment_pin, :boolean, default: false, after: :comment
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
