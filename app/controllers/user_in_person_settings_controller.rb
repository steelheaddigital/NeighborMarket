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

class UserInPersonSettingsController < ApplicationController
  include Settings
  before_filter :authenticate_user!
  load_and_authorize_resource

  def update
    @in_person_settings = UserInPersonSetting.find_or_initialize_by(user_id: current_user.id)

    if @in_person_settings.update_attributes(params[:user_in_person_setting])
      redirect_to user_payment_settings_path, notice: 'Your payment information was successfully saved.'
    else
      @settings_view_directory = "user_#{@processor_settings.processor_type.underscore}_settings/form"
      processor_setting_class = "User#{@processor_settings.processor_type}Setting".constantize
      @settings = processor_setting_class.find_or_initialize_by(user_id: current_user.id)

      render 'user_payment_settings/index', layout: 'layouts/seller'
    end
  end
end
