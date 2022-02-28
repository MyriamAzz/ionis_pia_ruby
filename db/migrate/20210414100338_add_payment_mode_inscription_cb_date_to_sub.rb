class AddPaymentModeInscriptionCbDateToSub < ActiveRecord::Migration[6.0]
  def change
    add_column :user_financier_subscriptions, :payment_mode_inscription_cb_date, :date, after: :payment_mode_inscription
  end
end
