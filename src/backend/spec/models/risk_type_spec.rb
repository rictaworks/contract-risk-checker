require "rails_helper"

RSpec.describe RiskType, type: :model do
  describe "validations" do
    it "is valid with unique name" do
      rt = RiskType.new(name: "損害賠償", description: "損害賠償に関するリスク")
      expect(rt).to be_valid
    end

    it "is invalid without name" do
      rt = RiskType.new(description: "損害賠償に関するリスク")
      expect(rt).not_to be_valid
    end

    it "is invalid with a duplicate name" do
      RiskType.create!(name: "損害賠償")
      rt2 = RiskType.new(name: "損害賠償")
      expect(rt2).not_to be_valid
    end
  end

  describe "associations" do
    it "has many risk_analyses" do
      association = described_class.reflect_on_association(:risk_analyses)
      expect(association.macro).to eq :has_many
      expect(association.options[:dependent]).to eq :restrict_with_error
    end
  end
end
