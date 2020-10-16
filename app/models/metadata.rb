class Metadata < ApplicationRecord
  belongs_to :service
  validates :locale, :data, :created_by, presence: true
end
