class Transaction < ApplicationRecord
  validates :nature, presence: true
  validates :transaction_type, presence: true
end
