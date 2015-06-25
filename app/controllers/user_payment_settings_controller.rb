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

class UserPaymentSettingsController < ApplicationController
  include Settings
  before_filter :authenticate_user!

  def index
    @settings_view_directory = "user_#{@processor_settings.processor_type.underscore}_settings/form"
    processor_setting_class = "User#{@processor_settings.processor_type}Setting".constantize
    @settings = processor_setting_class.find_or_initialize_by(user_id: current_user.id)
    @in_person_settings = UserInPersonSetting.find_or_initialize_by(user_id: current_user.id)

    respond_to do |format|
      format.html { render layout: 'layouts/seller' }
    end
  end
  
end
