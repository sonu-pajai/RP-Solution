class CreateRpTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :rp_transactions do |t|
      t.references :reporting_entity, null: false, foreign_key: true
      t.references :reporting_unit, null: false, foreign_key: true
      t.references :period, null: false, foreign_key: true
      t.string :counterparty, null: false
      t.string :transaction_type, null: false
      t.string :nature, null: false
      t.string :sub_nature, null: false
      t.decimal :amount, null: false

      t.timestamps
    end
  end
end
