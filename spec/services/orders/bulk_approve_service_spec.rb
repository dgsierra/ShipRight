require 'rails_helper'

RSpec.describe Orders::BulkApproveService do
  let(:user) { create(:user) }

  describe "#call" do
    it "approves all pending orders" do
      orders = create_list(:order, 3, status: "pending", user: user)
      result = described_class.new(orders.map(&:id), user: user).call

      expect(result.approved_count).to eq(3)
      expect(result.failed_ids).to be_empty
      orders.each { |o| expect(o.reload.status).to eq("approved") }
    end

    it "skips orders that cannot be approved and records failed ids" do
      pending_order   = create(:order, status: "pending", user: user)
      delivered_order = create(:order, :delivered, user: user)

      result = described_class.new([pending_order.id, delivered_order.id], user: user).call

      expect(result.approved_count).to eq(1)
      expect(result.failed_ids).to contain_exactly(delivered_order.id)
    end

    it "handles empty id list gracefully" do
      result = described_class.new([], user: user).call
      expect(result.approved_count).to eq(0)
      expect(result.failed_ids).to be_empty
    end
  end
end
