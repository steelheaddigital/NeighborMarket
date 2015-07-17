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

  before_filter :authenticate_user!, :set_view_directory
  load_and_authorize_resource

  def create
    @in_person_settings = current_user.user_in_person_setting
    @settings = current_user.build_user_paypal_express_setting(params[:user_paypal_express_setting])
    request_permissions_url = @settings.verify_account(true)

    if request_permissions_url
      redirect_to request_permissions_url
    else
      render 'user_payment_settings/index', layout: 'layouts/seller'
    end
  end

  def update
    @in_person_settings = current_user.user_in_person_setting
    @settings = UserPaypalExpressSetting.find(params[:id])

    if params['commit'] == 'Verify Account'
      @settings.assign_attributes(params[:user_paypal_express_setting])
      refund_permission_granted = @settings.permission_granted?('REFUND')
      request_permissions_result = @settings.verify_account(!refund_permission_granted)
      if request_permissions_result
        if request_permissions_result.is_a? String
          redirect_to request_permissions_result
        else
          redirect_to user_payment_settings_path, notice: 'Your Paypal account information was successfully updated.'
        end
      else
        render 'user_payment_settings/index', layout: 'layouts/seller'
      end
    elsif params['commit'] == 'Unlink Account'
      if @settings.destroy
        redirect_to user_payment_settings_path, notice: 'Your Paypal account was successfully unlinked.'
      else
        render 'user_payment_settings/index', layout: 'layouts/seller'
      end
    end
  end

  def grant_permissions
    @in_person_settings = current_user.user_in_person_setting
    @settings = current_user.user_paypal_express_setting
    request_token = params['request_token']
    verifier = params['verification_code']

    if @settings.grant_permissions(request_token, verifier)
      redirect_to user_payment_settings_path, notice: 'Your Paypal account information was successfully verified.'
    else
      render 'user_payment_settings/index', layout: 'layouts/seller'
    end
  end
  
  def set_view_directory
    @settings_view_directory = 'user_paypal_express_settings/form'
  end
end
