class OrderLineItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price_cents, numericality: { greater_than_or_equal_to: 0 }

  def line_total_cents
    quantity * unit_price_cents
  end

  def line_total_dollars
    line_total_cents / 100.0
  end
end
