class Metadata < ApplicationRecord
  belongs_to :service
  validates :locale, :data, :created_by, presence: true

  scope :by_locale, ->(locale) { where(locale: locale) }
  scope :latest_version, -> { ordered.first }
  scope :ordered, -> { order(created_at: :desc) }
  scope :all_versions, -> { select(:id, :created_at) }
end
