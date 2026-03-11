FactoryBot.define do
  factory :audit_entry do
    association :auditable, factory: :order
    event { "status_changed" }
    association :user
    whodunnit { "Staff Member" }
    changes_data { { status: ["pending", "approved"] } }
  end
end
