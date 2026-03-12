# frozen_string_literal: true

module Tracking
  class SyncTrackingEventsService
    Result = Struct.new(:success?, :new_events_count, :error, keyword_init: true)

    def initialize(order, carrier_client: Carriers::FakeCarrierClient)
      @order = order
      @carrier_client = carrier_client
    end

    def call
      return failure("Order has no tracking number") if @order.tracking_number.blank?

      result = @carrier_client.fetch_tracking(@order.tracking_number)

      unless result.success?
        return failure(result.error)
      end

      new_events_count = persist_new_events(result.events)
      Result.new(success?: true, new_events_count: new_events_count, error: nil)
    rescue StandardError => e
      Rails.logger.error("[Tracking::SyncTrackingEventsService] Error: #{e.message}")
      failure(e.message)
    end

    private

    def persist_new_events(events)
      existing_keys = existing_event_keys

      new_events = events.reject do |event|
        existing_keys.include?(event_key(event))
      end

      new_events.each do |event|
        @order.tracking_events.create!(
          carrier: event[:carrier],
          tracking_number: event[:tracking_number],
          status: event[:status],
          description: event[:description],
          location: event[:location],
          occurred_at: event[:occurred_at],
          raw_payload: event[:raw_payload]
        )
      end

      new_events.length
    end

    def existing_event_keys
      @order.tracking_events
            .pluck(:tracking_number, :status, :occurred_at)
            .map { |tn, st, oa| "#{tn}:#{st}:#{oa}" }
            .to_set
    end

    def event_key(event)
      "#{event[:tracking_number]}:#{event[:status]}:#{event[:occurred_at]}"
    end

    def failure(message)
      Result.new(success?: false, new_events_count: 0, error: message)
    end
  end
end
