class RemoveNotNullFromPeriodInRpMasters < ActiveRecord::Migration[8.0]
  def change
    change_column_null :rp_masters, :period_id, true
  end
end
