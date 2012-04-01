class SecondLevelCategory < ActiveRecord::Base
  belongs_to :top_level_category
  has_one :inventory
  validates :name, :presence => true
end
