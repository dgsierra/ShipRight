FactoryBot.define do
  factory :order do
    sequence(:reference) { |n| "SR-TEST#{n.to_s.rjust(4, '0')}" }
    status { "pending" }
    customer_name { "John Doe" }
    customer_email { "john@example.com" }
    total_cents { 5000 }
    association :user

    trait :approved do
      status { "approved" }
    end

    trait :shipped do
      status { "shipped" }
      tracking_number { "TRK12345" }
      carrier { "FakeCarrier" }
    end

    trait :delivered do
      status { "delivered" }
      tracking_number { "TRK12345" }
      carrier { "FakeCarrier" }
    end

    trait :cancelled do
      status { "cancelled" }
    end
  end
end
