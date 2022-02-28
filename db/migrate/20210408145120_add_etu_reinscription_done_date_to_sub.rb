class AddEtuReinscriptionDoneDateToSub < ActiveRecord::Migration[6.0]
  def change
    add_column :user_financier_subscriptions, :etudiant_reinscription_done_date, :datetime, after: :frais_scolarite_done_date
  end
end
