class User < ActiveRecord::Base
  acts_as_indexed :fields => [:username, :first_name, :last_name]
  has_and_belongs_to_many :roles
  has_many :inventory_items, :dependent => :destroy
  has_many :carts, :dependent => :destroy
  has_many :orders, :dependent => :destroy
  has_attached_file :photo, :styles => { :medium => "300x300>", :thumb => "100x100>" }
  
  validates :username, :uniqueness => true
  validates :username, 
            :first_name, 
            :last_name, 
            :initial, 
            :address, 
            :city, 
            :state, 
            :country, 
            :zip, :presence => true, :unless => :auto_create
  validates :phone, :presence => true, :if => :seller?
  validates :payment_instructions, :presence => true, :if => :seller?
  validates :delivery_instructions, :presence => true, :if => :buyer?
  validates_format_of :phone,
                      :with => %r{\(?[0-9]{3}\)?[-. ]?[0-9]{3}[-. ]?[0-9]{4}},
                      :message => "must be valid phone number",
                      :if => :phone?
  validates_format_of :zip,
                      :with => %r{\d{5}(-\d{4})?},
                      :message => "should be like 12345 or 12345-1234",
                      :unless => :auto_create
  
  validates_presence_of :email, :if => :email_required?
  validates_uniqueness_of :email, :allow_blank => true, :if => :email_changed?
  validates_format_of :email, :with => /\A[^@]+@[^@]+\z/, :allow_blank => true, :if => :email_changed?

  validates_presence_of :password, :if => :password_required?
  validates_confirmation_of :password, :if => :password_required?
  validates_length_of :password, :within => 6..128, :allow_blank => true
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :confirmable, :timeoutable

  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login, :become_seller, :become_buyer
  attr_writer :auto_create
  
  def auto_create
    @auto_create || false
  end
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :login, :username, :email, :password, :password_confirmation, :remember_me,
                  :first_name, :last_name, :initial, :phone, :address, :city, :state, :country, :zip, :aboutme, :approved_seller, :payment_instructions, :delivery_instructions, :become_seller, :become_buyer, :listing_approval_style, :photo
  
  def set_auto_created_updated_at
    if auto_created && auto_create_updated_at.nil? && confirmed?
      self.auto_create_updated_at = Time.current
      self.save
    end
  end
  
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
  
  #Override the devise callback method that sends emails on create to send a different one for auto signups
  def send_on_create_confirmation_instructions
    send_devise_notification(:confirmation_instructions) if !auto_created
    UserMailer.delay.auto_create_user_mail(self) if auto_created
  end
  
  def password_required?
    !auto_create && (!persisted? || !password.nil? || !password_confirmation.nil? || (auto_created && auto_create_updated_at.nil?))
  end

  def email_required?
    true
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
    return self.seller? && self.approved_seller
  end
  
  def self.search(keywords, role, seller_approved, seller_approval_style)
    
    scope = self
    
    if(role.present?)
      scope = scope.joins(:roles).where('roles.name = ?', "#{role.downcase}")
    end
    if(seller_approved.present?)
      scope = scope.where('approved_seller = ?', seller_approved)
    end
    if(seller_approval_style.present?)
      scope = scope.where('listing_approval_style = ?', "#{seller_approval_style}")
    end
    if(keywords.present?)
      scope = scope.find_with_index(keywords)
    else
      scope.all
    end
    
  end
  
  def auto_create_user
    self.auto_create = true
    self.auto_created = true
    return self.save
  end
  
end
