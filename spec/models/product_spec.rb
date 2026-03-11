require 'rails_helper'

RSpec.describe Product, type: :model do
  subject(:product) { build(:product) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:sku) }
  it { is_expected.to validate_uniqueness_of(:sku) }
  it { is_expected.to have_many(:order_line_items) }

  describe "#unit_price_dollars" do
    it "converts cents to dollars" do
      product = build(:product, unit_price_cents: 2500)
      expect(product.unit_price_dollars).to eq(25.0)
    end
  end
end
