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

class UserMailer < BaseMailer
  
  def user_contact_mail(user, message)
    @message = message
    site_settings = SiteSetting.first
    mail( :to => user.email,
          :reply_to => message.email,
          :subject => "#{site_settings.site_name} - #{message.subject}")
  end
  
  def auto_create_user_mail(user)
    site_settings = SiteSetting.first
    @user = user
    mail( :to => user.email, 
          :subject => "The manager at #{site_settings.site_name} has created a new account for you")
  end
  
  def manager_install_mail(user)
    @user = user
    mail( :to => user.email, 
          :subject => "Your Neighbor Market site has been installed. Confirm your Manager account now.")
  end
  
end
