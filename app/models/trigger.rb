# Trigger class
class Trigger < ApplicationRecord
  validates :email, presence: true
  validates :rate, numericality: { greater_than: 0 }
  validates :email, uniqueness: { scope: %i[currency operation kind rate],
                                  message: 'already has this trigger' }

  @email = 'Email'

  class << self
    attr_reader :email
  end

  def self.new_email(email)
    @email = email
    Rails.cache.delete('views//')
  end
end
