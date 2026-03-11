require 'rails_helper'

RSpec.describe AuditEntry, type: :model do
  it { is_expected.to belong_to(:auditable) }
  it { is_expected.to belong_to(:user).optional }
  it { is_expected.to validate_presence_of(:event) }

  describe ".log" do
    let(:user)  { create(:user) }
    let(:order) { create(:order, user: user) }

    it "creates an audit entry" do
      expect {
        AuditEntry.log(auditable: order, event: "test_event", user: user, changes: { foo: "bar" })
      }.to change(AuditEntry, :count).by(1)
    end

    it "sets the whodunnit from the user" do
      entry = AuditEntry.log(auditable: order, event: "test_event", user: user)
      expect(entry.whodunnit).to eq(user.display_name)
    end

    it "defaults whodunnit to 'system' when no user" do
      entry = AuditEntry.log(auditable: order, event: "auto_event")
      expect(entry.whodunnit).to eq("system")
    end
  end
end
