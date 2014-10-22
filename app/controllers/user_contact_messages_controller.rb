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

class UserContactMessagesController < ApplicationController
  load_and_authorize_resource :class => UserContactMessage
  
  def new
    @message = UserContactMessage.new
    @user = User.find(params[:id])
    authorize! :contact, @user
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  def create
    @message = UserContactMessage.new(params[:user_contact_message])
    @user = User.find(params[:id])
    authorize! :contact, @user
    
    respond_to do |format|
      if @message.valid?
        UserMailer.delay.user_contact_mail(@user, @message)
        format.html { redirect_to(user_path(@user), :notice => "Your message was successfully sent.") }
        format.js { redirect_to(user_path(@user), :notice => "Your message was successfully sent.") }
      else
        format.html { render "new" }
        format.js { render "new", :layout => false, :status => 403 }
      end
    end
    
  end

end