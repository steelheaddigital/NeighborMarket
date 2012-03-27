class User < ActiveRecord::Base
  has_many :roles, :dependent => :destroy
  has_many :inventories, :dependent => :destroy
  accepts_nested_attributes_for :roles, :allow_destroy => true 
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
                  :first_name, :last_name, :initial, :phone, :address, :city, :state, :country, :zip, :aboutme, :roles_attributes, :become_seller
  
  #override the devise authentication to use either username or email to login
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.strip.downcase }]).first
  end
  
  def active_for_authentication?
    user = self.roles.find_by_rolable_type("Seller")
    super && 
      if user && !user.seller.approved? && !self.role?("Buyer") && !self.role?("Manager")  
        user.seller.approved?
      else
        true
      end
  end 

  def inactive_message
    user = self.roles.find_by_rolable_type("Seller")
    if user && !user.seller.approved? && !self.role?("Buyer") && !self.role?("Manager") 
      :not_approved 
    else 
      super 
    end 
  end
  
  def role?(role)
    if self.roles.find_by_rolable_type(role)
      true
    else
      false
    end
  end
  
  def seller?
    self.roles.each do |role|
      if role.rolable_type == "Seller" || self.become_seller
        return true
      end
      return false
    end
  end
  
  def phone?
    if self.phone == nil || self.phone == ""
      return false
    else
      return true
    end
  end
  
  def self.search(keywords, role, seller_approved, seller_approval_style)
    
    scope = self
    
    if(keywords.present?)
      scope = scope.where('first_name LIKE ? OR last_name LIKE ? OR username LIKE ?', "%#{keywords}%", "%#{keywords}%", "%#{keywords}%")
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
