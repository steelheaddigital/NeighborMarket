class InventoryItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :top_level_category
  belongs_to :second_level_category
  has_many :cart_items
  
  attr_accessible :top_level_category_id, :second_level_category_id, :name, :price, :price_unit, :quantity_available, :description
  
  validates :top_level_category_id, 
    :second_level_category_id,
    :price,
    :price_unit,
    :quantity_available,
    :presence => true
  
  validates :price, :numericality => {:greater_than_or_equal_to => 0.01}
  validates :quantity_available, :numericality => {:greater_than_or_equal_to => 0}
  
  before_destroy :ensure_not_referenced_by_any_cart_item
  
  def self.search(keywords)
    scope = self.where("quantity_available > 0")
    
    #split the incoming keywords on space and then join them with the PGSQL OR operator
    keyword_list = keywords.split(/ /).join("|")
    
    top_level_category = TopLevelCategory.where('to_tsvector(name) @@ to_tsquery(?)', keyword_list).first
    if(top_level_category)
      top_level_category_id = top_level_category.id
    end
    
    
    second_level_category = SecondLevelCategory.where('to_tsvector(name) @@ to_tsquery(?)', keyword_list).first
    if(second_level_category)
      second_level_category_id = second_level_category.id
    end
    
    if(keywords.present?)
      scope = scope.where('top_level_category_id = ? OR second_level_category_id = ? OR to_tsvector(name) @@ to_tsquery(?) OR to_tsvector(description) @@ to_tsquery(?)', top_level_category_id, second_level_category_id, keyword_list, keyword_list)
    end
    
    scope.all
    
  end
  
  def decrement_quantity_available(quantity)
    self.quantity_available -= quantity unless self.quantity_available.zero?
    self.save!
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
