require 'rails_helper'

RSpec.describe Tracking::SyncTrackingEventsService do
  let(:user)  { create(:user) }
  let(:order) { create(:order, :shipped, user: user) }

  let(:fake_client_class) do
    Class.new do
      def self.fetch_tracking(tracking_number)
        new.fetch_tracking(tracking_number)
      end

      def fetch_tracking(_tracking_number)
        Carriers::FakeCarrierClient::TrackingResult.new(
          success?: true,
          events: [
            {
              carrier: "TestCarrier",
              tracking_number: "TRK12345",
              status: "in_transit",
              description: "In transit",
              location: "Chicago, IL",
              occurred_at: 1.day.ago,
              raw_payload: {}
            }
          ],
          error: nil
        )
      end
    end
  end

  describe "#call" do
    context "when order has a tracking number" do
      it "creates new tracking events" do
        service = described_class.new(order, carrier_client: fake_client_class)
        expect {
          service.call
        }.to change { order.tracking_events.count }.by(1)
      end

      it "returns success result" do
        result = described_class.new(order, carrier_client: fake_client_class).call
        expect(result.success?).to be true
        expect(result.new_events_count).to eq(1)
      end

      it "does not duplicate existing events" do
        described_class.new(order, carrier_client: fake_client_class).call
        expect {
          described_class.new(order, carrier_client: fake_client_class).call
        }.not_to change { order.tracking_events.count }
      end
    end

    context "when order has no tracking number" do
      let(:order) { create(:order, status: "pending", user: user) }

      it "returns failure" do
        result = described_class.new(order, carrier_client: fake_client_class).call
        expect(result.success?).to be false
        expect(result.error).to include("no tracking number")
      end
    end

    context "when carrier client fails" do
      let(:failing_client) do
        Class.new do
          def self.fetch_tracking(_)
            Carriers::FakeCarrierClient::TrackingResult.new(
              success?: false, events: [], error: "Connection timeout"
            )
          end
        end
      end

      it "returns failure" do
        result = described_class.new(order, carrier_client: failing_client).call
        expect(result.success?).to be false
        expect(result.error).to eq("Connection timeout")
      end
    end
  end
end
