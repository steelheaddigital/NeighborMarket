class Seller < ActiveRecord::Base
  has_one :user, :as => :rolable
  validates :payment_instructions, :presence => true
  
  def active_for_authentication? 
    super && approved? 
  end 

  def inactive_message 
    if !approved? 
      :not_approved 
    else 
      super
    end 
  end
end
