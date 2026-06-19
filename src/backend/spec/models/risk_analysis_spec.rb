require "rails_helper"

RSpec.describe RiskAnalysis, type: :model do
  let(:user) { User.create!(google_sub: "sub_user", display_name: "User") }
  let(:contract) { Contract.create!(user: user, title: "Contract", original_filename: "c.pdf", status: "UPLOADED") }
  let(:clause) { Clause.create!(contract: contract, clause_text: "第1条 ...", order_index: 1) }
  let(:risk_level) { RiskLevel.create!(name: "高", score_weight: 30) }
  let(:risk_type) { RiskType.create!(name: "損害賠償") }

  describe "validations" do
    it "is valid with all fields" do
      analysis = RiskAnalysis.new(
        clause: clause,
        risk_level: risk_level,
        risk_type: risk_type,
        problem_description: "問題あり",
        suggestion_text: "修正案",
        analysis_status: "SUCCESS",
        retry_count: 0
      )
      expect(analysis).to be_valid
    end

    it "is valid with optional fields as nil" do
      analysis = RiskAnalysis.new(
        clause: clause,
        risk_level: nil,
        risk_type: nil,
        analysis_status: "PENDING",
        retry_count: 0
      )
      expect(analysis).to be_valid
    end

    it "is invalid without analysis_status" do
      analysis = RiskAnalysis.new(clause: clause, analysis_status: nil)
      expect(analysis).not_to be_valid
    end

    it "is invalid with invalid analysis_status" do
      analysis = RiskAnalysis.new(clause: clause, analysis_status: "INVALID_STATUS")
      expect(analysis).not_to be_valid
    end

    it "is invalid with negative retry_count" do
      analysis = RiskAnalysis.new(clause: clause, analysis_status: "PENDING", retry_count: -1)
      expect(analysis).not_to be_valid
    end

    it "is invalid with a duplicate clause_id" do
      RiskAnalysis.create!(clause: clause, analysis_status: "PENDING", retry_count: 0)
      dup = RiskAnalysis.new(clause: clause, analysis_status: "PENDING", retry_count: 0)
      expect(dup).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to clause" do
      expect(described_class.reflect_on_association(:clause).macro).to eq :belongs_to
    end

    it "belongs to risk_level" do
      association = described_class.reflect_on_association(:risk_level)
      expect(association.macro).to eq :belongs_to
      expect(association.options[:optional]).to eq true
    end

    it "belongs to risk_type" do
      association = described_class.reflect_on_association(:risk_type)
      expect(association.macro).to eq :belongs_to
      expect(association.options[:optional]).to eq true
    end
  end
end
