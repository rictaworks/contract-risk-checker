require 'rails_helper'

RSpec.describe Clause, type: :model do
  let(:user) { User.create!(google_sub: 'sub_user', display_name: 'User') }
  let(:contract) { Contract.create!(user: user, title: 'Contract', original_filename: 'c.pdf', status: 'UPLOADED') }

  describe 'validations' do
    it 'is valid with clause_text and order_index' do
      clause = Clause.new(contract: contract, clause_text: '第1条 ...', order_index: 1)
      expect(clause).to be_valid
    end

    it 'is invalid without clause_text' do
      clause = Clause.new(contract: contract, order_index: 1)
      expect(clause).not_to be_valid
    end

    it 'is invalid without order_index' do
      clause = Clause.new(contract: contract, clause_text: '第1条 ...')
      expect(clause).not_to be_valid
    end

    it 'is invalid with non-integer order_index' do
      clause = Clause.new(contract: contract, clause_text: '第1条 ...', order_index: 1.5)
      expect(clause).not_to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to contract' do
      expect(described_class.reflect_on_association(:contract).macro).to eq :belongs_to
    end

    it 'has one risk_analysis' do
      association = described_class.reflect_on_association(:risk_analysis)
      expect(association.macro).to eq :has_one
      expect(association.options[:dependent]).to eq :destroy
    end
  end
end
