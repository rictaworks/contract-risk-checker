class ContractType < ApplicationRecord
  has_many :contracts, dependent: :nullify
  validates :name, presence: true, uniqueness: true
end
