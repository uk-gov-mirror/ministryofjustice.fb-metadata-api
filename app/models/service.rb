class Service < ApplicationRecord
  has_many :metadata, dependent: :destroy
  validates :name, :created_by, presence: true
  accepts_nested_attributes_for :metadata

  def last_metadata
    metadata.order(created_at: :desc).first
  end
end
