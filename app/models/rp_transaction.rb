class RpTransaction < ApplicationRecord
  belongs_to :reporting_entity
  belongs_to :reporting_unit
  belongs_to :period

  validates :counterparty, :transaction_type, :nature, :sub_nature, :amount, presence: true
end
