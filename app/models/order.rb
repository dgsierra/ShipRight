class Order < ApplicationRecord
  STATUSES = %w[pending approved shipped delivered cancelled].freeze

  VALID_TRANSITIONS = {
    "pending"   => %w[approved cancelled],
    "approved"  => %w[shipped cancelled],
    "shipped"   => %w[delivered],
    "delivered" => [],
    "cancelled" => []
  }.freeze

  belongs_to :user
  has_many :line_items, class_name: "OrderLineItem", dependent: :destroy
  has_many :products, through: :line_items
  has_many :tracking_events, dependent: :destroy
  has_many :audit_entries, as: :auditable, dependent: :destroy

  validates :reference, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :customer_name, presence: true
  validates :customer_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :total_cents, numericality: { greater_than_or_equal_to: 0 }

  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :recent, -> { order(created_at: :desc) }
  scope :with_tracking, -> { where.not(tracking_number: nil) }

  before_validation :generate_reference, on: :create

  def can_transition_to?(new_status)
    VALID_TRANSITIONS.fetch(status, []).include?(new_status.to_s)
  end

  def total_dollars
    total_cents / 100.0
  end

  def latest_tracking_event
    tracking_events.order(occurred_at: :desc).first
  end

  private

  def generate_reference
    self.reference ||= "SR-#{SecureRandom.alphanumeric(8).upcase}"
  end
end
