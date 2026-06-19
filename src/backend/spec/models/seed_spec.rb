require 'rails_helper'

RSpec.describe 'Seed Data', type: :model do
  before do
    Rails.application.load_seed
  end

  it 'populates the contract types master with exactly 7 records' do
    expect(ContractType.count).to eq(7)
    expect(ContractType.pluck(:name)).to match_array(['売買', '業務委託', 'NDA', '雇用', '賃貸借', 'ライセンス', 'その他'])
  end

  it 'populates the risk levels master with exactly 4 records' do
    expect(RiskLevel.count).to eq(4)
    expect(RiskLevel.pluck(:name)).to match_array(['高', '中', '低', 'なし'])
  end

  it 'populates the risk types master with exactly 12 records' do
    expect(RiskType.count).to eq(12)
    expect(RiskType.pluck(:name)).to match_array([
      '損害賠償', '秘密保持', '競業避止', '自動更新', '解除条件',
      '準拠法', '仲裁', '支払', '期間', '知的財産', '不可抗力', 'その他'
    ])
  end
end
