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

class UserRegistrationsController < Devise::RegistrationsController
  include Settings

  prepend_before_filter :require_no_authentication, :only => [ :new, :create, :cancel ]
  prepend_before_filter :authenticate_scope!, :only => [:become_seller, :become_buyer, :edit, :update, :destroy]
  before_filter :configure_permitted_parameters
  
  def new
    authorize! :manage, :manager if params[:user][:user_type] == "manager"
    resource = build_resource({})
    user_type = params[:user][:user_type]
    add_resource_role(resource, user_type)

    respond_with resource
  end
  
  def create
    authorize! :manage, :manager if params[:user][:user_type] == "manager"
    build_resource(sign_up_params)
    user_type = params[:user][:user_type]
    add_resource_role(resource, user_type)
    
    if resource.save    # customized code
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        if resource.role?("seller")
          send_new_seller_email(resource)
        end
        expire_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords(resource)
      respond_with resource
    end
  end
  
  def edit
    super
  end
  
  def update
    # required for settings form to submit when password is left blank
    if params[:user][:password].blank?
      params[:user].delete("password")
      params[:user].delete("password_confirmation")
    end
    
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)
    
    if params[:user][:become_seller] == "true"
      resource.become_seller = true
      add_role(resource, "seller")
    end
    if params[:user][:become_buyer] == "true"
      resource.become_buyer = true
      add_role(resource, "buyer")
    end

    if resource.update_attributes(params[resource_name])
      if is_navigational_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ? :update_needs_confirmation : :updated
        # customized code begin
        if resource.become_seller
          set_flash_message :notice, :became_seller
          send_new_seller_email(resource)
        else
          set_flash_message :notice, flash_key
        end
        # customized code end
      end
      sign_in resource_name, resource, :bypass => true if !resource.become_seller && !resource.become_buyer
      respond_with resource, :location => after_update_path_for(resource)
    else
      clean_up_passwords resource
      respond_with_navigational(resource) do
        if params[:user][:become_seller] == "true"
          render :become_seller
        else
          respond_with resource
        end
      end
    end
  end

  def destroy
    resource.soft_delete
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    set_flash_message :notice, :destroyed if is_navigational_format?
    respond_with_navigational(resource){ redirect_to after_sign_out_path_for(resource_name) }
  end
  
  def seller_inactive_signup
  end
  
  def inactive_signup
  end
  
  def become_seller
    add_role(resource, "seller")
  end
  
  def become_buyer
    add_role(resource, "buyer")
  end
  
  def terms_of_service
    @terms_of_service = @site_contents.terms_of_service
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  private
  
  #Override the devise method to send new sellers to a custom page
  def after_inactive_sign_up_path_for(resource)
    if resource.seller?
      user_seller_inactive_signup_path 
    else
      user_inactive_signup_path
    end
  end
  
  private
  
  def send_new_seller_email(user)
    managers = User.joins(:roles).where(:roles => {:name => "manager"})
    managers.each do |manager|
      ManagerMailer.delay.new_seller_mail(user, manager)
    end
  end
  
  def add_resource_role(resource, user_type)
    if user_type == "buyer"
      add_role(resource, "buyer")
    end
    if user_type == "seller"
      add_role(resource, "seller")
    end
  end
  
  def add_role(resource, role)
      resource.roles.build(name: role.downcase)
  end
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:username, :first_name, :last_name, :address, :city, :state, :country, :zip, :phone, :aboutme, :delivery_instructions, :terms_of_service,
        :email, :password, :password_confirmation, :photo)
    end
    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(:username, :first_name, :last_name, :address, :city, :state, :country, :zip, :phone, :aboutme, :delivery_instructions, :terms_of_service,
        :email, :password, :password_confirmation, :photo)
    end
  end
  
end
