require 'rails_helper'

RSpec.describe Order, type: :model do
  subject(:order) { build(:order) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:customer_name) }
    it { is_expected.to validate_presence_of(:customer_email) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_inclusion_of(:status).in_array(Order::STATUSES) }
    it { is_expected.to validate_uniqueness_of(:reference) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:line_items) }
    it { is_expected.to have_many(:tracking_events) }
    it { is_expected.to have_many(:audit_entries) }
  end

  describe "#can_transition_to?" do
    subject(:order) { build(:order, status: "pending") }

    it "allows valid transitions" do
      expect(order.can_transition_to?("approved")).to be true
      expect(order.can_transition_to?("cancelled")).to be true
    end

    it "rejects invalid transitions" do
      expect(order.can_transition_to?("shipped")).to be false
      expect(order.can_transition_to?("delivered")).to be false
    end

    context "when delivered" do
      subject(:order) { build(:order, :delivered) }

      it "has no valid transitions" do
        expect(order.can_transition_to?("cancelled")).to be false
        expect(order.can_transition_to?("shipped")).to be false
      end
    end
  end

  describe "#total_dollars" do
    it "converts cents to dollars" do
      order = build(:order, total_cents: 4999)
      expect(order.total_dollars).to eq(49.99)
    end
  end

  describe "reference auto-generation" do
    it "generates a reference on create if blank" do
      user = create(:user)
      order = Order.create!(
        customer_name: "Test", customer_email: "t@example.com",
        total_cents: 100, user: user, status: "pending"
      )
      expect(order.reference).to match(/\ASR-[A-Z0-9]{8}\z/)
    end
  end
end
