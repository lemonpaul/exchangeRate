class Trigger < ApplicationRecord
  validates :email, presence: true
  validates :rate, numericality: { greater_than: 0 }
  validates :email, uniqueness: {scope: [:currency, :operation, :kind, :rate], message: "already has this trigger"}
end
