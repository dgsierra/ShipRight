FactoryBot.define do
  factory :tracking_event do
    association :order
    carrier { "FakeCarrier" }
    tracking_number { "TRK12345" }
    status { "in_transit" }
    description { "In transit to destination" }
    location { "Chicago, IL" }
    occurred_at { 1.day.ago }
    raw_payload { { simulated: true } }
  end
end
