class CreatePayouts < ActiveRecord::Migration[6.1]
  def change
    create_table :payouts do |t|
      t.references :school_program
      t.references :centre
      t.references :user
      t.integer :gc_status
      t.string :gc_id
      t.string :gc_reference
      t.float :gc_amount
      t.datetime :gc_created_at
      t.datetime :gc_arrival_at
      t.boolean :exported, default: false
      t.datetime :exported_at
      t.timestamps
    end
  end
end
