class User < ActiveRecord::Base
  has_and_belongs_to_many :roles
  has_many :inventory_items, :dependent => :destroy
  has_many :carts, :dependent => :destroy
  
  validates :username, :uniqueness => true
  validates :username, 
            :first_name, 
            :last_name, 
            :initial, 
            :address, 
            :city, 
            :state, 
            :country, 
            :zip, :presence => true
  validates :phone, :presence => true, :if => :seller?
  validates :payment_instructions, :presence => true, :if => :seller?
  validates :delivery_instructions, :presence => true, :if => :buyer?
  validates_format_of :phone,
                      :with => %r{\(?[0-9]{3}\)?[-. ]?[0-9]{3}[-. ]?[0-9]{4}},
                      :message => "must be valid phone number",
                      :if => :phone?
  validates_format_of :zip,
                      :with => %r{\d{5}(-\d{4})?},
                      :message => "should be like 12345 or 12345-1234"
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login, :become_seller
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :login, :username, :email, :password, :password_confirmation, :remember_me,
                  :first_name, :last_name, :initial, :phone, :address, :city, :state, :country, :zip, :aboutme, :approved_seller, :payment_instructions, :delivery_instructions, :become_seller
  
  #override the devise authentication to use either username or email to login
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.strip.downcase }]).first
  end
  
  def active_for_authentication?
    super && 
      if self.seller? && !self.approved_seller? && !self.buyer? && !self.manager?  
        false
      else
        true
      end
  end 

  #override the devise method to display the inactive message for unapproved sellers who attempt to log in
  def inactive_message
    if self.seller? && !self.approved_seller? && !self.buyer? && !self.manager?   
      :not_approved 
    else 
      super 
    end 
  end
  
  def role?(role)
    is_role = !!self.roles.find_by_name(role)
    return is_role
  end
  
  def seller?
    self.roles.each do |role|
      if role.name == "seller" || self.become_seller
        return true
      end
    end
    return false
  end
  
  def buyer?
    self.roles.each do |role|
      if role.name == "buyer"
        return true
      end
    end
    return false
  end
  
  def manager?
    self.roles.each do |role|
      if role.name == "manager"
        return true
      end
    end
    return false
  end
  
  def phone?
    if self.phone == nil || self.phone == ""
      return false
    else
      return true
    end
  end
  
  def approved_seller?
    self.roles.each do |role|
      if role.name =="seller" && self.approved_seller
        return true
      end
    end
    return false
  end
  
  def self.search(keywords, role, seller_approved, seller_approval_style)
    
    scope = self
    
    keywordList = keywords.downcase.split(/ /)
    
    if(keywords.present?)
      scope = scope.where('LOWER(first_name) IN(?) OR LOWER(last_name) IN(?) OR LOWER(username) IN(?)', keywordList, keywordList, keywordList)
    end
    if(role.present?)
      scope = scope.where('roles.rolable_type = ?', "#{role}").includes(:roles)
    end
    if(seller_approved.present?)
      scope = scope.where('sellers.approved = ?', seller_approved).includes(:roles => :seller)
    end
    if(seller_approval_style.present?)
      scope = scope.where('sellers.listing_approval_style = ?', "#{seller_approval_style}").includes(:roles => :seller)
    end
    
    scope.all
    
  end
  
end
