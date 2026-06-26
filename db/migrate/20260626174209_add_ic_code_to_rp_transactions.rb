class AddIcCodeToRpTransactions < ActiveRecord::Migration[8.0]
  def change
    add_column :rp_transactions, :ic_code, :integer
  end
end
