class InventoryItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :top_level_category
  belongs_to :second_level_category
  has_many :cart_items
  
  attr_accessible :id, :top_level_category_id, :second_level_category_id, :user_id, :name, :price, :price_unit, :quantity_available, :description
  
  validates :top_level_category_id, 
    :second_level_category_id,
    :price,
    :price_unit,
    :quantity_available,
    :presence => true
  
  validates :price, :numericality => {:greater_than_or_equal_to => 0.01}
  validates :quantity_available, :numericality => {:greater_than_or_equal_to => 1}
  
  before_destroy :ensure_not_referenced_by_any_cart_item
  
  def self.search(keywords)
    scope = self
    
    keywordList = keywords.downcase.split(/ /)
    
    top_level_category = TopLevelCategory.where('LOWER(name) IN(?)', keywordList).first
    if(top_level_category)
      top_level_category_id = top_level_category.id
    end
    
    
    second_level_category = SecondLevelCategory.where('LOWER(name) IN(?)', keywordList).first
    if(second_level_category)
      second_level_category_id = second_level_category.id
    end
    
    if(keywords.present?)
      scope = scope.where('top_level_category_id = ? OR second_level_category_id = ? OR LOWER(name) LIKE ? OR LOWER(description) LIKE ?', top_level_category_id, second_level_category_id, "%#{keywords}%", "%#{keywords}%")
    end
    
    scope.all
    
  end
  
  private
  
  def ensure_not_referenced_by_any_cart_item
    
    if cart_items.empty?
      return true
    else
      errors.add(:base, "Cart Items Present")    
      return false
    end
  end
  
end
