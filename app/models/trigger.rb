# Trigger class
class Trigger < ApplicationRecord
  validates :email, presence: true
  validates :rate, numericality: { greater_than: 0 }
  validates :email, uniqueness: { scope: %i[currency operation kind rate],
                                  message: I18n.t(:uniq_trigger) }

  @email = 'Email'

  class << self
    attr_accessor :email
  end
end
