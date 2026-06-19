class Contract < ApplicationRecord
  belongs_to :user
  belongs_to :contract_type, optional: true
  has_many :clauses, dependent: :destroy
  has_one :report, dependent: :destroy
  validates :title, :original_filename, :status, presence: true

  STATUSES = %w[UPLOADED EXTRACTED PARSED ANALYZING ANALYZED REPORTED FAILED].freeze
  validates :status, inclusion: { in: STATUSES }

  # アクセス制御スコープ
  scope :for_user, ->(user) { where(user: user) }
end
