class Service < ApplicationRecord
  has_many :metadata, dependent: :destroy
  validates :name, :created_by, presence: true
  accepts_nested_attributes_for :metadata
end
