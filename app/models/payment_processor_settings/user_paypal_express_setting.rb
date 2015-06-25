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

class UserPaypalExpressSetting < ActiveRecord::Base
  include PaymentProcessor

  belongs_to :payment_processor_setting
  belongs_to :user

  crypt_keeper :access_token, :access_token_secret, encryptor: :aes_new, key: "#{Rails.application.secrets.secret_key_base}", salt: "#{Rails.application.secrets.secret_key_salt}"

  validate :business_account?

  attr_accessible :email_address

  def verify_account(request_permissions)
    ActiveRecord::Base.transaction do
      begin
        verify_response = payment_processor.verify_account(email_address, user.first_name, user.last_name)
        self.account_id = verify_response[:account_id]
        self.account_type = verify_response[:account_type]

        if request_permissions == true && save
          payment_processor.request_permissions
        else
          save
        end
      rescue PaymentProcessor::PaymentError => e
        self.account_id = nil
        self.account_type = nil
        errors.add(:base, e.message)
        raise ActiveRecord::Rollback, e.message
      end
    end
  rescue ActiveRecord::RecordNotSaved
    false
  end

  def grant_permissions(request_token, verifier)
    ActiveRecord::Base.transaction do
      begin
        access_token = payment_processor.get_access_token(request_token, verifier)
        self.access_token = access_token[:access_token]
        self.access_token_secret = access_token[:access_token_secret]
        save
      rescue PaymentProcessor::PaymentError => e
        self.access_token = nil
        self.access_token_secret = nil
        errors.add(:base, e.message)
        raise ActiveRecord::Rollback, e.message
      end
    end
  rescue ActiveRecord::RecordNotSaved
    false
  end

  def permissions_granted?
    !access_token_secret.nil? && !access_token.nil?
  end

  def account_confirmed?
    !account_id.nil? && permissions_granted?
  end

  def permission_granted?(permission)
    result = false
    if access_token
      granted_permissions = payment_processor.get_permissions(access_token)
      result = granted_permissions.include?(permission)
    end
    return result
  rescue PaymentProcessor::PaymentError => e
    errors.add(:base, e.message)
  end

  private

  def business_account?
    return unless account_type.downcase != 'business'
    self.account_id = nil
    errors.add(:base, 'You must have a Paypal business account. You can <a href="https://www.paypal.com/signup/account">sign up for a new Paypal business account</a> or <a href="https://www.paypal.com/us/cgi-bin/webscr?cmd=_run-signup-upgrade-link">upgrade your existing account</a>.'.html_safe)
  end
end
