class Role < ActiveRecord::Base
  belongs_to :user
  belongs_to :rolable, :polymorphic => true
  has_many :buyer, :class_name => "Buyer",
                     :foreign_key => "rolable_id"
  has_many :seller, :class_name => "Seller",
                      :foreign_key => "rolable_id"
  belongs_to :manager, :class_name => "Manager",
                      :foreign_key => "rolable_id"
  
  accepts_nested_attributes_for :rolable, :seller, :buyer, :manager, :allow_destroy => true
  attr_accessible :rolable_attributes, :seller_attributes, :buyer_attributes, :manager_attributes
  before_destroy {|role| role.rolable.destroy }
  
end
