class AddMonthNumberToPeriods < ActiveRecord::Migration[8.0]
  def change
    add_column :periods, :month_number, :integer
  end
end
