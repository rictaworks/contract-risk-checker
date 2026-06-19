require "rails_helper"

RSpec.describe Report, type: :model do
  let(:user) { User.create!(google_sub: "sub_user", display_name: "User") }
  let(:contract) { Contract.create!(user: user, title: "Contract", original_filename: "c.pdf", status: "UPLOADED") }

  describe "validations" do
    it "is valid with all fields" do
      report = Report.new(
        contract: contract,
        total_score: 50,
        high_count: 1,
        medium_count: 2,
        low_count: 3,
        overall_comment: "Good",
        pdf_path: "/path/to/pdf"
      )
      expect(report).to be_valid
    end

    it "is valid with total_score as nil" do
      report = Report.new(
        contract: contract,
        total_score: nil,
        high_count: 0,
        medium_count: 0,
        low_count: 0
      )
      expect(report).to be_valid
    end

    it "is invalid with invalid total_score" do
      report = Report.new(contract: contract, total_score: 101, high_count: 0, medium_count: 0, low_count: 0)
      expect(report).not_to be_valid

      report2 = Report.new(contract: contract, total_score: -1, high_count: 0, medium_count: 0, low_count: 0)
      expect(report2).not_to be_valid
    end

    it "is invalid with negative counts" do
      report = Report.new(contract: contract, total_score: 50, high_count: -1, medium_count: 0, low_count: 0)
      expect(report).not_to be_valid
    end

    it "is invalid with a duplicate contract" do
      Report.create!(contract: contract, total_score: 50, high_count: 0, medium_count: 0, low_count: 0)
      report2 = Report.new(contract: contract, total_score: 60, high_count: 0, medium_count: 0, low_count: 0)
      expect(report2).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to contract" do
      expect(described_class.reflect_on_association(:contract).macro).to eq :belongs_to
    end
  end
end
