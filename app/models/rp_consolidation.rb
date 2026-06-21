class RpConsolidation < ApplicationRecord
  belongs_to :rp_master
  belongs_to :reporting_entity
  belongs_to :period

  delegate :unique_code, :name, to: :rp_master, prefix: true
end
