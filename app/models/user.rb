class User < ActiveRecord::Base
  has_many :roles, :dependent => :destroy
  accepts_nested_attributes_for :roles, :allow_destroy => true 
  validates :username, :uniqueness => true
  validates :username, :first_name, :last_name, :initial, :address, :city, :state, :country, :zip, :presence => true
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :login, :username, :email, :password, :password_confirmation, :remember_me,
                  :first_name, :last_name, :initial, :phone, :address, :city, :state, :country, :zip, :aboutme, :roles_attributes
  
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
      super # Use whatever other message 
    end 
  end

  def role?(role)
    if self.roles.find_by_rolable_type(role)
      true
    else
      false
    end
  end
end
