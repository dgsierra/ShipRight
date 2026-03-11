FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "staff#{n}@shipright.io" }
    name { "Staff Member" }
    password { "password123" }
    staff { true }
  end
end
