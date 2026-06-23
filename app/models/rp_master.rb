class RpMaster < ApplicationRecord
  belongs_to :reporting_entity, optional: true
  belongs_to :period, optional: true
  belongs_to :created_by, class_name: "User", optional: true
  belongs_to :approved_by, class_name: "User", optional: true
  belongs_to :admin_approved_by, class_name: "User", optional: true

  after_create :generate_unique_code

  validates :name, presence: true
  validates :category, presence: true
  validates :specific_relationship, presence: true
  validates :pan, format: { with: /\A[A-Z]{5}[0-9]{4}[A-Z]\z/, message: "must be a valid PAN (e.g. ABCDE1234F)" }, allow_blank: true
  validate :dob_must_be_in_past

  private

  def generate_unique_code
    update_column(:unique_code, "RP_#{id}")
  end

  def dob_must_be_in_past
    if dob_or_incorporation.present? && dob_or_incorporation > Date.current
      errors.add(:dob_or_incorporation, "should not be a future date")
    end
  end
end
