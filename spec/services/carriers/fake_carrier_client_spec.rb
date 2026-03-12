require 'rails_helper'

RSpec.describe Carriers::FakeCarrierClient do
  let(:client) { described_class.new }

  describe "#fetch_tracking" do
    it "returns a successful result with events" do
      result = client.fetch_tracking("TRK12345678")
      # May fail ~5% of the time in simulation – retry logic not needed in tests
      # We stub the private method to ensure success
      allow(client).to receive(:simulate_failure?).and_return(false)
      result = client.fetch_tracking("TRK12345678")
      expect(result.success?).to be true
      expect(result.events).to be_an(Array)
      expect(result.events).not_to be_empty
    end

    it "returns events with required keys" do
      allow(client).to receive(:simulate_failure?).and_return(false)
      result = client.fetch_tracking("STABLE001")
      event = result.events.first
      expect(event).to include(:carrier, :tracking_number, :status, :occurred_at)
    end

    it "simulates failures occasionally" do
      allow(client).to receive(:simulate_failure?).and_return(true)
      result = client.fetch_tracking("TRK99999")
      expect(result.success?).to be false
      expect(result.error).to be_present
    end

    it "uses the class-level .fetch_tracking shortcut" do
      allow_any_instance_of(described_class).to receive(:simulate_failure?).and_return(false)
      result = described_class.fetch_tracking("TRK-CLASS")
      expect(result.success?).to be true
    end
  end
end
