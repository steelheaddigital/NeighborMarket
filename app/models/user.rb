class User < ActiveRecord::Base
  belongs_to :rolable, :polymorphic => true
  belongs_to :buyer, :class_name => "Buyer",
                     :foreign_key => "rolable_id"
  belongs_to :seller, :class_name => "Seller",
                      :foreign_key => "rolable_id"
  
  validates :username, :uniqueness => true
  validates :username, :first_name, :last_name, :initial, :address, :city, :state, :country, :zip, :presence => true
  validates_associated_bubbling :rolable
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :login, :username, :email, :password, :password_confirmation, :remember_me,
                  :first_name, :last_name, :initial, :phone, :address, :city, :state, :country, :zip, :aboutme
  
  #override the devise authentication to use either username or email to login
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.strip.downcase }]).first
  end
  
  def active_for_authentication?
    super && 
      if self.rolable_type == "Seller" 
        self.seller.approved?
      else
        true
      end
  end 

  def inactive_message 
    if self.rolable_type == "Seller" && !self.seller.approved?
      :not_approved 
    else 
      super # Use whatever other message 
    end 
  end

end
