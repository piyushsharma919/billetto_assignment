class Event < ApplicationRecord
  validates :source, :external_id, :title, :starts_at, presence: true

  validates :external_id, uniqueness: { scope: :source }

  validates :minimum_price_cents,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 },
            allow_nil: true

  validates :ends_at, comparison: { greater_than: :starts_at }, if: :ends_at?
end
