class Metadata < ApplicationRecord
  belongs_to :service
  validates :locale, :data, :created_by, presence: true

  scope :by_locale, lambda { |locale| where(locale: locale) }
  scope :latest_version, -> { order(created_at: :desc).first }
end
