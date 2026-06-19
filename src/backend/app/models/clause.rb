class Clause < ApplicationRecord
  belongs_to :contract
  has_one :risk_analysis, dependent: :destroy

  validates :clause_text, presence: true
  validates :order_index, presence: true, numericality: { only_integer: true }
end
