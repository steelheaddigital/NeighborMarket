#
#Copyright 2013 Neighbor Market
#
#This file is part of Neighbor Market.
#
#Neighbor Market is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#Neighbor Market is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with Neighbor Market.  If not, see <http://www.gnu.org/licenses/>.
#

class User < ActiveRecord::Base
  include PgSearch
  acts_as_token_authenticatable
  
  pg_search_scope :user_search, :against => [:username, :first_name, :last_name]
  has_and_belongs_to_many :roles
  has_many :inventory_items, :dependent => :destroy
  has_many :carts, :dependent => :destroy
  has_many :orders, :dependent => :destroy
  has_many :order_change_requests
  has_many :inventory_item_change_requests
  has_attached_file :photo, 
                    :styles => { :medium => "300x300>", :thumb => "100x100>" },
                    :default_url => ':style/default_user.png'
  has_many :reviews
  has_one :user_paypal_express_setting
  has_one :user_in_person_setting
  has_one :user_preference
  
  validates :username, :uniqueness => true, :unless => :auto_create
  validates :username, :presence => true, :unless => :auto_create
  validates :first_name, 
            :last_name, :presence => true, :if => :additional_fields_required?
  validates :address, 
            :city, 
            :state, 
            :country, 
            :zip, :presence => true, :if => :address_required?
  validates :phone, :presence => true, :if => :seller?
  validates :delivery_instructions, :presence => true, :if => :delivery_instructions_required?
  validates_format_of :phone,
                      :with => %r{\(?[0-9]{3}\)?[-. ]?[0-9]{3}[-. ]?[0-9]{4}},
                      :message => "must be valid phone number",
                      :if => :phone?
  validates_format_of :zip,
                      :with => %r{\d{5}(-\d{4})?},
                      :message => "should be like 12345 or 12345-1234",
                      :if => :zip?
  
  validates_presence_of :email, :if => :email_required?
  validates_uniqueness_of :email, :allow_blank => true, :if => :email_changed?
  validates_format_of :email, :with => /\A[^@]+@[^@]+\z/, :allow_blank => true, :if => :email_changed?

  validates_presence_of :password, :if => :password_required?
  validates_confirmation_of :password, :if => :password_required?
  validates_length_of :password, :within => 6..128, :allow_blank => true
  validates :terms_of_service, acceptance: { accept: true }, :if => :tos_required?
  validates_attachment_content_type :photo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
  
  before_save { valid? || true }
  after_save { errors.clear || true }
  after_create :create_user_in_person_setting, if: :seller?
  after_create :create_user_preference
  before_update :set_auto_created_updated_at, if: :auto_created_pending_update?
  after_update :create_user_in_person_setting, if: :become_seller
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :confirmable, :timeoutable

  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login, :become_seller, :skip_confirmation_email
  attr_writer :auto_create
  
  scope :active, -> { where(deleted_at: nil) }
  scope :confirmed, -> { where('confirmed_at IS NOT NULL').active }
  scope :active_sellers, -> { joins(:roles).where("roles.name='seller' AND users.approved_seller=true").confirmed }
  scope :active_buyers, -> { joins(:roles).where("roles.name='buyer'").confirmed }
  
  def auto_create
    @auto_create || false
  end
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :login, :username, :email, :password, :password_confirmation, :remember_me,
                  :first_name, :last_name, :phone, :address, :city, :state, :country, 
                  :zip, :aboutme, :approved_seller, :delivery_instructions, 
                  :become_seller, :listing_approval_style, :photo, :skip_confirmation_email, :terms_of_service
  
  def set_auto_created_updated_at
    self.auto_create_updated_at = Time.current if self.valid?
  end
  
  def auto_created_pending_update?
    auto_created && auto_create_updated_at.nil?
  end
  
  #override the devise authentication to use either username or email to login
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    where(conditions).where(['lower(username) = :value OR lower(email) = :value', { value: login.strip.downcase }]).first
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
    send_confirmation_instructions if !auto_created && !skip_confirmation_email
    send_auto_create_confirmation_instructions if auto_created && !skip_confirmation_email
  end
  
  def pending_reconfirmation?
    (self.class.reconfirmable && unconfirmed_email.present?) || auto_created_pending_update?
  end
  
  def send_auto_create_confirmation_instructions
    unless @raw_confirmation_token
      generate_confirmation_token!
    end
    
    UserMailer.delay.auto_create_user_mail(self, @raw_confirmation_token)
  end
  
  # Send confirmation instructions by email
  def send_confirmation_instructions
    unless @raw_confirmation_token
      generate_confirmation_token!
    end

    opts = pending_reconfirmation? ? { to: unconfirmed_email } : {}
    send_devise_notification(:confirmation_instructions, @raw_confirmation_token, opts) if !auto_created || !auto_create_updated_at.nil?
    UserMailer.delay.auto_create_user_mail(self, @raw_confirmation_token) if auto_created_pending_update?
  end
  
  def password_required?
    !auto_create && (!persisted? || !password.nil? || !password_confirmation.nil? || auto_created_pending_update?)
  end

  def email_required?
    true
  end
  
  def additional_fields_required?
    if seller? && !auto_create
      return true
    end
    false
  end
  
  def address_required?
    site_settings = SiteSetting.instance
    if site_settings.delivery_only?
      !auto_create
    else
      additional_fields_required?
    end
  end
  
  def delivery_instructions_required?
    site_settings = SiteSetting.instance
    buyer? && site_settings.delivery_only?
  end
  
  def tos_required?
    tos_required = SiteContent.instance.require_terms_of_service?
    !auto_create && tos_required
  end
  
  def role?(role)
    is_role = !!roles.find_by_name(role)
    is_role
  end
  
  def seller?
    roles.each do |role|
      if role.name == 'seller' || become_seller && deleted_at.nil?
        return true
      end
    end
    false
  end
  
  def buyer?
    roles.each do |role|
      if role.name == 'buyer' && deleted_at.nil?
        return true
      end
    end
    false
  end
  
  def manager?
    roles.each do |role|
      if role.name == 'manager' && deleted_at.nil?
        return true
      end
    end
    false
  end
  
  def phone?
    if phone.nil? || phone == ''
      return false
    else
      return true
    end
  end
  
  def approved_seller?
    self.seller? && approved_seller
  end
  
  def self.search(keywords, role, seller_approved, seller_approval_style)
    
    scope = active
    
    scope = scope.joins(:roles).where('roles.name = ?', "#{role.downcase}") if role.present?
    scope = scope.where('approved_seller = ?', seller_approved) if seller_approved.present?
    scope = scope.where('listing_approval_style = ?', "#{seller_approval_style}") if seller_approval_style.present?
    scope = scope.user_search(keywords) if keywords.present?
    scope
  
  end
  
  def auto_create_user
    self.auto_create = true
    self.auto_created = true
    save
  end
  
  def add_role(role_type)
    unless self.role?(role_type)
      new_role = Role.new
      new_role.name = role_type.downcase
      roles.build(new_role.attributes)
    end
  end
  
  def remove_role(role_type)
    if self.role?(role_type)
      role = roles.find_by_name(role_type)
      role.destroy
    end
  end
  
  def soft_delete
    self.deleted_at = Time.now
    self.email = nil
    self.encrypted_password = ''
    self.reset_password_token = nil
    self.reset_password_sent_at = nil
    self.remember_created_at = nil
    self.sign_in_count = 0
    self.current_sign_in_at = nil
    self.last_sign_in_at = nil
    self.current_sign_in_ip = nil
    self.last_sign_in_ip = nil
    self.first_name = nil
    self.last_name = nil
    self.phone = nil
    self.address = nil
    self.city = nil
    self.state = nil
    self.country = nil
    self.zip = nil
    self.aboutme = nil
    self.delivery_instructions = nil
    self.approved_seller = false
    self.listing_approval_style = ''
    photo.clear
    roles.clear
    user_paypal_express_setting.delete if user_paypal_express_setting
    user_in_person_setting.delete if user_in_person_setting
    inventory_items.each(&:paranoid_destroy)
    
    save(validate: false)
  end
  
  def avg_seller_rating
    ratings = inventory_items.joins(:reviews).average('reviews.rating')
    ratings.round(2) unless ratings.nil?
  end

  def current_inventory
    inventory_items.joins(:order_cycles).where("order_cycles.status = 'current'")
  end

  def categories
    current_inventory.joins(:second_level_category)
      .select('second_level_categories.name')
      .group('second_level_categories.id')
      .pluck('second_level_categories.name')
  end

  def current_order
    orders.find_by(order_cycle_id: OrderCycle.current_cycle_id, canceled: false)
  end

  def create_user_in_person_setting
    build_user_in_person_setting
    user_in_person_setting.accept_in_person_payments = true if PaymentProcessorSetting.current_processor_type == 'InPerson'
    user_in_person_setting.save(validate: false)
  end

  def online_payment_processor_configured?
    if PaymentProcessorSetting.current_processor_type != 'InPerson'
      user_setting = eval("User#{PaymentProcessorSetting.current_processor_type}Setting".underscore)
      !user_setting.nil? && user_setting.configuration_complete?
    else
      false
    end
  end
  
end
