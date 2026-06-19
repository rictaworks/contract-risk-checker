require 'rails_helper'

RSpec.describe RiskLevel, type: :model do
  describe 'validations' do
    it 'is valid with name and score_weight' do
      rl = RiskLevel.new(name: '高', score_weight: 30)
      expect(rl).to be_valid
    end

    it 'is invalid without name' do
      rl = RiskLevel.new(score_weight: 30)
      expect(rl).not_to be_valid
    end

    it 'is invalid without score_weight' do
      rl = RiskLevel.new(name: '高')
      expect(rl).not_to be_valid
    end

    it 'is invalid with non-integer score_weight' do
      rl = RiskLevel.new(name: '高', score_weight: 3.5)
      expect(rl).not_to be_valid
    end

    it 'is invalid with negative score_weight' do
      rl = RiskLevel.new(name: '高', score_weight: -1)
      expect(rl).not_to be_valid
    end

    it 'is invalid with a duplicate name' do
      RiskLevel.create!(name: '高', score_weight: 30)
      rl2 = RiskLevel.new(name: '高', score_weight: 30)
      expect(rl2).not_to be_valid
    end
  end

  describe 'associations' do
    it 'has many risk_analyses' do
      association = described_class.reflect_on_association(:risk_analyses)
      expect(association.macro).to eq :has_many
      expect(association.options[:dependent]).to eq :restrict_with_error
    end
  end
end
