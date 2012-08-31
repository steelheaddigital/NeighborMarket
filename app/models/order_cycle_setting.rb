class OrderCycleSetting < ActiveRecord::Base
  
  attr_accessible :recurring, :interval, :padding, :padding_interval
  
  validates :interval, :presence => true, :if => 'recurring?'
  validates :padding, :numericality => { :only_integer => true }
  
  def self.new_setting(settings)
    current_order_cycle_settings = self.first
    if current_order_cycle_settings
      current_order_cycle_settings.assign_attributes(settings)
      return current_order_cycle_settings
    else
      new_settings = self.new(settings)
      return new_settings
    end
  end
  
end
