require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with google_sub" do
      user = User.new(google_sub: "sub_123", display_name: "Alice")
      expect(user).to be_valid
    end

    it "is invalid without google_sub" do
      user = User.new(display_name: "Alice")
      expect(user).not_to be_valid
    end

    it "is invalid with a duplicate google_sub" do
      User.create!(google_sub: "sub_123", display_name: "Alice")
      user2 = User.new(google_sub: "sub_123", display_name: "Bob")
      expect(user2).not_to be_valid
    end
  end

  describe "associations" do
    it "has many contracts" do
      association = described_class.reflect_on_association(:contracts)
      expect(association.macro).to eq :has_many
      expect(association.options[:dependent]).to eq :restrict_with_error
    end
  end

  describe "scopes" do
    describe ".by_sub" do
      it "returns users matching google_sub" do
        user1 = User.create!(google_sub: "sub_1", display_name: "Alice")
        user2 = User.create!(google_sub: "sub_2", display_name: "Bob")

        expect(User.by_sub("sub_1")).to include(user1)
        expect(User.by_sub("sub_1")).not_to include(user2)
      end
    end
  end
end
