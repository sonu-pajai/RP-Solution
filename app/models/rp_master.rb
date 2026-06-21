class RpMaster < ApplicationRecord
  belongs_to :reporting_entity
  belongs_to :period, optional: true
  belongs_to :created_by, class_name: "User", optional: true
  belongs_to :approved_by, class_name: "User", optional: true
  belongs_to :admin_approved_by, class_name: "User", optional: true

  after_create :generate_unique_code

  validates :name, presence: true
  validates :category, presence: true
  validates :specific_relationship, presence: true

  private

  def generate_unique_code
    update_column(:unique_code, "RP_#{id}")
  end
end
