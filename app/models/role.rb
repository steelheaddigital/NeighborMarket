class Role < ActiveRecord::Base
  has_and_belongs_to_many :users
  
  attr_accessible :name
  
  validates :name, :inclusion => { :in => %w(buyer seller manager),
      :message => "%{value} is not a valid role" }
end
