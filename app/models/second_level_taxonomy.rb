class SecondLevelTaxonomy < ActiveRecord::Base
  belongs_to :top_level_taxonomy
  has_one :inventory
  validates :name, :presence => true
end
