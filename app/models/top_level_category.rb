class TopLevelCategory < ActiveRecord::Base
  has_many :second_level_categories
  has_one :inventory
  validates :name, :presence => true
end
