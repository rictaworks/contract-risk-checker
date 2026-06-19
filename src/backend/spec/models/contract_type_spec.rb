require 'rails_helper'

RSpec.describe ContractType, type: :model do
  describe 'validations' do
    it 'is valid with unique name' do
      ct = ContractType.new(name: 'NDA', description: 'Non Disclosure Agreement')
      expect(ct).to be_valid
    end

    it 'is invalid without name' do
      ct = ContractType.new(description: 'Non Disclosure Agreement')
      expect(ct).not_to be_valid
    end

    it 'is invalid with a duplicate name' do
      ContractType.create!(name: 'NDA')
      ct2 = ContractType.new(name: 'NDA')
      expect(ct2).not_to be_valid
    end
  end

  describe 'associations' do
    it 'has many contracts' do
      association = described_class.reflect_on_association(:contracts)
      expect(association.macro).to eq :has_many
      expect(association.options[:dependent]).to eq :nullify
    end
  end
end
