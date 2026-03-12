class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  has_many :orders, dependent: :restrict_with_error
  has_many :audit_entries, dependent: :nullify

  validates :name, presence: true
  validates :staff, inclusion: { in: [ true, false ] }

  scope :staff, -> { where(staff: true) }

  def display_name
    name.presence || email
  end
end
