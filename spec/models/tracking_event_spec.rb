require 'rails_helper'

RSpec.describe TrackingEvent, type: :model do
  it { is_expected.to belong_to(:order) }
  it { is_expected.to validate_presence_of(:carrier) }
  it { is_expected.to validate_presence_of(:tracking_number) }
  it { is_expected.to validate_presence_of(:status) }
  it { is_expected.to validate_presence_of(:occurred_at) }
end
