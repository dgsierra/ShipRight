require 'rails_helper'

RSpec.describe Orders::StatusTransitionService do
  let(:user)  { create(:user) }
  let(:order) { create(:order, status: "pending", user: user) }

  describe "#call" do
    context "with a valid transition" do
      it "transitions the order to the new status" do
        result = described_class.new(order, "approved", user: user).call
        expect(result.success?).to be true
        expect(order.reload.status).to eq("approved")
      end

      it "creates an audit entry" do
        expect {
          described_class.new(order, "approved", user: user).call
        }.to change { order.audit_entries.count }.by(1)
      end

      it "records the status change in the audit entry" do
        described_class.new(order, "approved", user: user).call
        entry = order.audit_entries.last
        expect(entry.changes_data["status"]).to eq(["pending", "approved"])
        expect(entry.whodunnit).to eq(user.display_name)
      end
    end

    context "with an invalid transition" do
      it "returns failure with a friendly message" do
        result = described_class.new(order, "delivered", user: user).call
        expect(result.success?).to be false
        expect(result.error).to include("Cannot transition")
      end

      it "does not change the order status" do
        described_class.new(order, "delivered", user: user).call
        expect(order.reload.status).to eq("pending")
      end
    end

    context "with an unknown status" do
      it "returns failure" do
        result = described_class.new(order, "bogus", user: user).call
        expect(result.success?).to be false
        expect(result.error).to include("not a valid")
      end
    end
  end
end
