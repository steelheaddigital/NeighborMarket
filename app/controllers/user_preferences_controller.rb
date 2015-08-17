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

class UserPreferencesController < ApplicationController
  acts_as_token_authentication_handler_for User
  load_and_authorize_resource
  
  def edit
    @preferences = current_user.user_preference
    @token = current_user.authentication_token
    @email = current_user.email
    render layout: 'no_header'
  end
  
  def update
    @preferences = UserPreference.find(params[:id])
    if @preferences.update_attributes(params[:user_preference])
      redirect_to :back, notice: 'Preferences successfully updated!'
    else
      render :edit
    end
  end
end
