class Transaction < ApplicationRecord
  scope :active, -> { where(active: true) }

  validates :nature, presence: true
  validates :transaction_type, presence: true
end
