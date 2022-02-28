class CreateLogSales < ActiveRecord::Migration[6.0]
  def change
    create_table :log_sales do |t|
      t.references :user_financier_subscription
      t.string :code_journal
      t.date :date_import
      t.string :numero_facture
      t.string :reference
      t.string :compte_general
      t.string :compte_tiers
      t.string :libelle
      t.string :type_ecriture
      t.string :analytique
      t.string :mode_reglement
      t.string :date_echeance
      t.float :debit
      t.float :credit
      t.string :nom_complet
      t.integer :annee
      t.integer :type_frais
      t.integer :modalite
      t.timestamps
    end
  end
end
