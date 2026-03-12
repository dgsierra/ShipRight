# frozen_string_literal: true

module Carriers
  class FakeCarrierClient
    CARRIER_NAME = "FakeCarrier"

    TrackingResult = Struct.new(:success?, :events, :error, keyword_init: true)

    SIMULATED_STATUSES = %w[
      label_created
      picked_up
      in_transit
      out_for_delivery
      delivered
    ].freeze

    def self.fetch_tracking(tracking_number)
      new.fetch_tracking(tracking_number)
    end

    def fetch_tracking(tracking_number)
      # Simulate occasional failures for realistic behavior
      if simulate_failure?
        return TrackingResult.new(
          success?: false,
          events: [],
          error: "Connection timeout (simulated)"
        )
      end

      events = generate_events(tracking_number)
      TrackingResult.new(success?: true, events: events, error: nil)
    rescue StandardError => e
      TrackingResult.new(success?: false, events: [], error: e.message)
    end

    private

    def simulate_failure?
      rand(100) < 5 # 5% failure rate
    end

    def generate_events(tracking_number)
      seed = tracking_number.sum
      rng = Random.new(seed)

      status_count = rng.rand(2..SIMULATED_STATUSES.length)
      statuses = SIMULATED_STATUSES.first(status_count)

      statuses.map.with_index do |status, idx|
        occurred_at = (status_count - idx).days.ago + rng.rand(0..3600).seconds

        {
          carrier: CARRIER_NAME,
          tracking_number: tracking_number,
          status: status,
          description: humanize_status(status),
          location: sample_location(rng),
          occurred_at: occurred_at,
          raw_payload: { simulated: true, seed_status: status }
        }
      end
    end

    def humanize_status(status)
      {
        "label_created"     => "Shipping label created",
        "picked_up"         => "Package picked up",
        "in_transit"        => "In transit to destination",
        "out_for_delivery"  => "Out for delivery",
        "delivered"         => "Package delivered"
      }.fetch(status, status.humanize)
    end

    def sample_location(rng)
      locations = [
        "New York, NY", "Chicago, IL", "Dallas, TX",
        "Los Angeles, CA", "Atlanta, GA", "Memphis, TN"
      ]
      locations[rng.rand(locations.length)]
    end
  end
end
