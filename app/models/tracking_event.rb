class TrackingEvent < ApplicationRecord
  belongs_to :order

  validates :carrier, presence: true
  validates :tracking_number, presence: true
  validates :status, presence: true
  validates :occurred_at, presence: true

  scope :recent, -> { order(occurred_at: :desc) }
end
