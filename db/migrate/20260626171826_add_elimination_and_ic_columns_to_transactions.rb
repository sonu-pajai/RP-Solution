class AddEliminationAndIcColumnsToTransactions < ActiveRecord::Migration[8.0]
  def change
    add_column :transactions, :elimination_required, :boolean
    add_column :transactions, :ic_code, :integer
    add_column :transactions, :main_code, :string
    add_column :transactions, :sub_code, :string
    add_column :transactions, :opposite_sub_code, :string
  end
end
