class RiskAnalysis < ApplicationRecord
  belongs_to :clause
  belongs_to :risk_level, optional: true
  belongs_to :risk_type, optional: true

  ANALYSIS_STATUSES = %w[PENDING PROCESSING SUCCESS RETRY FAILED].freeze
  validates :clause_id, uniqueness: true
  validates :analysis_status, presence: true, inclusion: { in: ANALYSIS_STATUSES }
  validates :retry_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
