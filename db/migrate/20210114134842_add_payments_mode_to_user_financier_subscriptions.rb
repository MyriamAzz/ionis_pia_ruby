class AddPaymentsModeToUserFinancierSubscriptions < ActiveRecord::Migration[6.0]
  def change
    add_column :user_financier_subscriptions, :payment_mode_inscription, :integer, after: :redoublant
    add_column :user_financier_subscriptions, :payment_mode_inscription_comment, :string, after: :payment_mode_inscription
    add_column :user_financier_subscriptions, :payment_mode_scolarite, :integer, after: :payment_mode_inscription_comment
    add_column :user_financier_subscriptions, :payment_mode_scolarite_comment, :string, after: :payment_mode_scolarite
  end
end
