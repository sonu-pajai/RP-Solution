class Relationship < ApplicationRecord
  CATEGORIES = [
    'Self', 'Subsidiary', 'Associate/Joint Venture',
    'Entity Controlled by KMP / Director', 'KMP related',
    'Holding Company', 'Investing Company', 'Director/KMP', 'Relatives of KMP'
  ].freeze

  validates :name, presence: true, uniqueness: true
  validates :category, presence: true, inclusion: { in: CATEGORIES }
end
