require 'rails_helper'

RSpec.describe OrderLineItem, type: :model do
  it { is_expected.to belong_to(:order) }
  it { is_expected.to belong_to(:product) }
  it { is_expected.to validate_numericality_of(:quantity).is_greater_than(0) }

  describe "#line_total_cents" do
    it "multiplies quantity by unit price" do
      item = build(:order_line_item, quantity: 3, unit_price_cents: 1000)
      expect(item.line_total_cents).to eq(3000)
    end
  end
end
