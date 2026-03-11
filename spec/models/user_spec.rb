require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to have_many(:orders) }
  it { is_expected.to have_many(:audit_entries) }

  describe "#display_name" do
    it "returns the name when present" do
      user = build(:user, name: "Alice")
      expect(user.display_name).to eq("Alice")
    end

    it "falls back to email when name is blank" do
      user = build(:user, name: "")
      expect(user.display_name).to eq(user.email)
    end
  end
end
