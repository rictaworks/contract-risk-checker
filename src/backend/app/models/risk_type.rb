class RiskType < ApplicationRecord
  has_many :risk_analyses, dependent: :restrict_with_error
  validates :name, presence: true, uniqueness: true
end
