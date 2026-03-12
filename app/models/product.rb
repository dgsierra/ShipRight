class Product < ApplicationRecord
  has_many :order_line_items, dependent: :restrict_with_error
  has_many :orders, through: :order_line_items

  validates :name, presence: true
  validates :sku, presence: true, uniqueness: true
  validates :unit_price_cents, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }

  def unit_price_dollars
    unit_price_cents / 100.0
  end
end
