class Report < ApplicationRecord
  belongs_to :contract

  validates :contract_id, uniqueness: true
  validates :total_score, allow_nil: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :high_count, :medium_count, :low_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
