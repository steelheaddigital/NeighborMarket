class TopLevelTaxonomy < ActiveRecord::Base
  has_many :second_level_taxonomies
  has_one :inventory
  validates :name, :presence => true
end
