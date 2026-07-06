class ReportDocument < ApplicationRecord
  belongs_to :reporting_entity, optional: true
  belongs_to :period, optional: true
  belongs_to :created_by, class_name: "User", optional: true

  validates :title, presence: true
  validates :content, presence: true
end
