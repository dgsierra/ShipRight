class TrackingSyncJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    order = Order.find_by(id: order_id)
    return unless order

    result = Tracking::SyncTrackingEventsService.new(order).call

    unless result.success?
      Rails.logger.warn("[TrackingSyncJob] Sync failed for order #{order.reference}: #{result.error}")
    end
  end
end
