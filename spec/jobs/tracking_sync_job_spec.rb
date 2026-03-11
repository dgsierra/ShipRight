require 'rails_helper'

RSpec.describe TrackingSyncJob, type: :job do
  let(:user)  { create(:user) }
  let(:order) { create(:order, :shipped, user: user) }

  it "calls the sync service for the given order" do
    expect(Tracking::SyncTrackingEventsService).to receive(:new)
      .with(order)
      .and_return(double(call: Tracking::SyncTrackingEventsService::Result.new(success?: true, new_events_count: 0, error: nil)))

    described_class.new.perform(order.id)
  end

  it "does nothing when order does not exist" do
    expect { described_class.new.perform(99999) }.not_to raise_error
  end
end
