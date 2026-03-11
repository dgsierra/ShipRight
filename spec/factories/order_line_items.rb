FactoryBot.define do
  factory :order_line_item do
    association :order
    association :product
    quantity { 1 }
    unit_price_cents { 1999 }
  end
end
