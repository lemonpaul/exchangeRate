class Trigger < ApplicationRecord
  validates :email, presence: true
  validates :rate, numericality: { greater_than: 0 }
  validates :email, uniqueness: {scope: [:currency, :operation, :kind, :rate], message: "already has this trigger"}
  after_commit :flush_cache
  
  def self.cached_all
    Rails.cache.fetch('triggers_cache') { all.to_a }
  end

  def flush_cache
    Rails.cache.delete('triggers_cache')
  end
end
