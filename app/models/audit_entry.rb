class AuditEntry < ApplicationRecord
  belongs_to :auditable, polymorphic: true
  belongs_to :user, optional: true

  validates :event, presence: true

  scope :recent, -> { order(created_at: :desc) }

  def self.log(auditable:, event:, user: nil, changes: {})
    create!(
      auditable: auditable,
      event: event,
      user: user,
      whodunnit: user&.display_name || "system",
      changes_data: changes
    )
  end
end
