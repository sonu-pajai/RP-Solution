class RemoveReportingEntityAndPeriodFromRpMasters < ActiveRecord::Migration[8.0]
  def change
    remove_column :rp_masters, :reporting_entity_id, :bigint
    remove_column :rp_masters, :period_id, :bigint
  end
end
