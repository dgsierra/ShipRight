FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    sequence(:sku) { |n| "SKU-#{n.to_s.rjust(3, '0')}" }
    unit_price_cents { 1999 }
    active { true }
  end
end
