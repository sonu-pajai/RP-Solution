class ChangeIcCodeToStringInTransactions < ActiveRecord::Migration[8.0]
  def up
    remove_column :transactions, :ic_code
    add_column :transactions, :ic_code, :string
    remove_column :rp_transactions, :ic_code
    add_column :rp_transactions, :ic_code, :string
  end

  def down
    remove_column :transactions, :ic_code
    add_column :transactions, :ic_code, :integer
    remove_column :rp_transactions, :ic_code
    add_column :rp_transactions, :ic_code, :integer
  end
end
