require 'rails_helper'

RSpec.describe Contract, type: :model do
  let(:user) { User.create!(google_sub: 'sub_user', display_name: 'User') }
  let(:other_user) { User.create!(google_sub: 'sub_other', display_name: 'Other') }
  let(:contract_type) { ContractType.create!(name: 'NDA') }

  describe 'validations' do
    it 'is valid with all required fields' do
      contract = Contract.new(
        user: user,
        title: 'NDA Contract',
        original_filename: 'nda.pdf',
        status: 'UPLOADED',
        contract_type: contract_type
      )
      expect(contract).to be_valid
    end

    it 'is invalid without title' do
      contract = Contract.new(user: user, original_filename: 'nda.pdf', status: 'UPLOADED')
      expect(contract).not_to be_valid
    end

    it 'is invalid without original_filename' do
      contract = Contract.new(user: user, title: 'NDA Contract', status: 'UPLOADED')
      expect(contract).not_to be_valid
    end

    it 'is invalid without status' do
      contract = Contract.new(user: user, title: 'NDA Contract', original_filename: 'nda.pdf', status: nil)
      expect(contract).not_to be_valid
    end

    it 'is invalid with an invalid status' do
      contract = Contract.new(user: user, title: 'NDA Contract', original_filename: 'nda.pdf', status: 'INVALID_STATUS')
      expect(contract).not_to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to user' do
      expect(described_class.reflect_on_association(:user).macro).to eq :belongs_to
    end

    it 'belongs to contract_type' do
      association = described_class.reflect_on_association(:contract_type)
      expect(association.macro).to eq :belongs_to
      expect(association.options[:optional]).to eq true
    end

    it 'has many clauses' do
      association = described_class.reflect_on_association(:clauses)
      expect(association.macro).to eq :has_many
      expect(association.options[:dependent]).to eq :destroy
    end

    it 'has one report' do
      association = described_class.reflect_on_association(:report)
      expect(association.macro).to eq :has_one
      expect(association.options[:dependent]).to eq :destroy
    end
  end

  describe 'scopes' do
    describe '.for_user' do
      it 'returns only contracts belonging to the specified user' do
        contract1 = Contract.create!(user: user, title: 'User Contract 1', original_filename: 'c1.pdf', status: 'UPLOADED')
        contract2 = Contract.create!(user: user, title: 'User Contract 2', original_filename: 'c2.pdf', status: 'UPLOADED')
        other_contract = Contract.create!(user: other_user, title: 'Other Contract', original_filename: 'c3.pdf', status: 'UPLOADED')

        results = Contract.for_user(user)
        expect(results).to include(contract1, contract2)
        expect(results).not_to include(other_contract)
      end
    end
  end
end
