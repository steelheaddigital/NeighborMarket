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

class ContactController < ApplicationController
  
  def index
    @layout = params['layout']
    @message = UserContactMessage.new
    
    if !@layout.nil?
      render :layout => @layout
    end
    
  end
  
  def create
    @message = UserContactMessage.new(params[:user_contact_message])
    @layout = params['layout']
    if @message.valid?
      users = User.joins(:roles).where('roles.name = ?', "manager")
      users.each do |user|
        UserMailer.delay.user_contact_mail(user, @message)
      end
      if !@layout.nil?
        redirect_to(contact_path(:layout => @layout), :notice => "Your message was successfully sent. We will get back to you soon.")
      else
        redirect_to(contact_path, :notice => "Your message was successfully sent. We will get back to you soon.")
      end
    else
      if !@layout.nil?
        render "index", :layout => @layout
      else
        render "index"
      end
    end
    
  end
  
end