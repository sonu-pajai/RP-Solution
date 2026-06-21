class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.string :nature
      t.string :transaction_type
      t.string :sub_type
      t.string :as18
      t.string :acb
      t.string :sebi

      t.timestamps
    end
  end
end
