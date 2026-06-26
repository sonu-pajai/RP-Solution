class AddMainCodeAndSubCodeToRpTransactions < ActiveRecord::Migration[8.0]
  def change
    add_column :rp_transactions, :main_code, :string
    add_column :rp_transactions, :sub_code, :string
  end
end
