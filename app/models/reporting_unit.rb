class ReportingUnit < ApplicationRecord
  belongs_to :reporting_entity

  validates :name, presence: true
end
