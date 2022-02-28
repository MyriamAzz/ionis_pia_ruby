class AddBooleanCommentaireToUserSubscriptions < ActiveRecord::Migration[6.0]
  def change
    add_column :user_financier_subscriptions, :special_case, :boolean, after: :statut_etu, default: false
  end
end
