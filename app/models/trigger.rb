# Trigger class
class Trigger < ApplicationRecord
  validates :email, presence: true
  validates :rate, numericality: { greater_than: 0 }
  validates :email, uniqueness: { scope: %i[currency operation kind rate],
                                  message: 'already has this trigger' }
  after_commit :flush_cache
  @email = 'Email'
  def self.cached_all
    Rails.cache.fetch('triggers_cache') { all.to_a }
  end

  def self.set_email(email)
    @email = email
  end

  def self.get_email
    @email
  end

  def flush_cache
    Rails.cache.delete('triggers_cache')
  end
end
