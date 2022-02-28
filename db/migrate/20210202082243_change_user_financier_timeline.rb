class ChangeUserFinancierTimeline < ActiveRecord::Migration[6.0]
  def change
    remove_column :user_financier_timelines, :school_year_id
    remove_column :user_financier_timelines, :formation_annee_id
    remove_column :user_financier_timelines, :statut

    add_column :user_financier_timelines, :user_financier_id, :integer, after: :user_id
    add_column :user_financier_timelines, :descr, :string, after: :user_financier_id
    add_column :user_financier_timelines, :comment, :boolean, default: false, after: :descr
  end
end
