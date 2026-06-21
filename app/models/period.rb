class Period < ApplicationRecord
  validates :month, presence: true, uniqueness: { scope: :financial_year }
  validates :financial_year, presence: true
end
