class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  ROLES = %w[maker checker approver admin].freeze

  validates :role, inclusion: { in: ROLES }

  ROLES.each do |r|
    define_method(:"#{r}?") { role == r }
  end
end
