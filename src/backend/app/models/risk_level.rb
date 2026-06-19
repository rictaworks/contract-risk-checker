class RiskLevel < ApplicationRecord
  has_many :risk_analyses, dependent: :restrict_with_error
  validates :name, presence: true, uniqueness: true
  validates :score_weight, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
