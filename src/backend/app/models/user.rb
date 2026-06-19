class User < ApplicationRecord
  has_many :contracts, dependent: :restrict_with_error
  validates :google_sub, presence: true, uniqueness: true

  # ユーザースコープ強制（他ユーザーのデータにアクセス不可）
  scope :by_sub, ->(sub) { where(google_sub: sub) }
end
