class AddActiveToTransactions < ActiveRecord::Migration[8.0]
  def change
    add_column :transactions, :active, :boolean, default: true, null: false
  end
end
