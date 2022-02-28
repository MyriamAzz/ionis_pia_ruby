class AddConfirmReinscriptionToSub < ActiveRecord::Migration[6.0]
  def change
    add_column :user_financier_subscriptions, :etudiant_confirm_reinscription, :boolean, default: false, after: :frais_scolarite_done_date
  end
end
