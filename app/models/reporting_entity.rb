class ReportingEntity < ApplicationRecord
  has_many :reporting_units, dependent: :destroy
  accepts_nested_attributes_for :reporting_units, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true, uniqueness: true
end
