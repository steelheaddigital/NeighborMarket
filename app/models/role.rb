class Role < ActiveRecord::Base
  belongs_to :user
  belongs_to :rolable, :polymorphic => true
  belongs_to :buyer, :class_name => "Buyer",
                     :foreign_key => "rolable_id"
  belongs_to :seller, :class_name => "Seller",
                      :foreign_key => "rolable_id"
  belongs_to :manager, :class_name => "Manager",
                      :foreign_key => "rolable_id"
  
  validates_associated_bubbling :rolable
  
  attr_accessible :rolable_id, :rolable_type
end
