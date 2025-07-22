class Manufacturer
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :external_id, type: String

  has_many :cart_items, dependent: :destroy

  validates :name, presence: true
  validates :external_id, presence: true, uniqueness: true

  index({ external_id: 1 }, { unique: true })
  index({ name: 1 })
end 