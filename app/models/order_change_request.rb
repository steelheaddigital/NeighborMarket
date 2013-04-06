class OrderChangeRequest < ActiveRecord::Base
  belongs_to :order
  belongs_to :user
  attr_accessible :complete, :description
end