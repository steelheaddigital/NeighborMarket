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

class UserPaypalExpressSettingsController < ApplicationController
  include Settings

  before_filter :authenticate_user!
  load_and_authorize_resource

  def create
    @in_person_settings = current_user.user_in_person_setting
    @settings = current_user.build_user_paypal_express_setting(params[:user_paypal_express_setting])
    request_permissions_url = @settings.verify_account(true)

    if request_permissions_url
      redirect_to request_permissions_url
    else
      @settings_view_directory = 'user_paypal_express_settings/form'
      render 'user_payment_settings/index', layout: 'layouts/seller'
    end
  end

  def update
    @in_person_settings = current_user.user_in_person_setting
    @settings = UserPaypalExpressSetting.find(params[:id])
    @settings.assign_attributes(params[:user_paypal_express_setting])
    refund_permission_granted = @settings.permission_granted?('REFUND')
    request_permissions_result = @settings.verify_account(!refund_permission_granted)

    if request_permissions_result
      if request_permissions_result.is_a? String
        redirect_to request_permissions_result
      else
        redirect_to user_payment_settings_path, notice: 'Your Paypal account information was successfully updated'
      end
    else
      @settings_view_directory = 'user_paypal_express_settings/form'
      render 'user_payment_settings/index', layout: 'layouts/seller'
    end
  end

  def grant_permissions
    @in_person_settings = current_user.user_in_person_setting
    @settings = current_user.user_paypal_express_setting
    request_token = params['request_token']
    verifier = params['verification_code']

    if @settings.grant_permissions(request_token, verifier)
      redirect_to user_payment_settings_path, notice: 'Your Paypal account information was successfully confirmed'
    else
      @settings_view_directory = 'user_paypal_express_settings/form'
      render 'user_payment_settings/index', layout: 'layouts/seller'
    end
  end
  
end
