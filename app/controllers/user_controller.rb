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

class UserController < ApplicationController
  require 'csv'
  before_filter :authenticate_user!, :except => [:show, :contact, :contact_form]
  load_and_authorize_resource

  def show
    @user = User.find(params[:id])
    @items_for_display = InventoryItem.joins(:order_cycles)
                                      .where("order_cycles.status = 'current' AND inventory_items.user_id = ?", params[:id])
    @message = UserContactMessage.new
    session[:last_search_path] = request.fullpath
    
    respond_to do |format|
      format.html
    end
  end
  
  def new
    @user = User.new
    
    respond_to do |format|
      format.html {render :partial => "new"}
    end
  end
  
  def create
    @user = User.new(params[:user])
    if params[:manager]
      @user.add_role('manager')
    end
    respond_to do |format|
      if @user.auto_create_user
        format.html { redirect_to add_users_management_index_path, notice: 'User successfully created!'}
      else
        format.html { render 'management/add_users', :layout => 'management' }
      end
    end
  end
  
  def edit
    @user = User.find(params[:id])
    @site_settings = SiteSetting.first
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    @user.soft_delete
    redirect_to :back, notice: 'User successfully deleted!'
  end
  
  def update
    # required for settings form to submit when password is left blank
    if params[:user][:password].blank?
      params[:user].delete("password")
      params[:user].delete("password_confirmation")
    end
    
    @user = User.find(params[:id])
    previous_seller_approved = @user.approved_seller?
    
    if(params[:manager])
      @user.add_role('manager')
    else
      @user.remove_role('manager')
    end
    
    respond_to do |format|
      if @user.update_attributes(params[:user])
        
        new_seller_approved = @user.approved_seller?
        
        if(previous_seller_approved == false && new_seller_approved == true)
          SellerMailer.delay.seller_approved_mail(@user)
        end
        
        format.html { redirect_to user_search_management_index_path, notice: 'User successfully updated!'}
        format.js { render :nothing => true }
      else
        format.html { render :edit }
        format.js { render :edit, :layout => false, :status => 403 }
      end
    end
  
  end
    
  def contact
    @message = UserContactMessage.new(params[:user_contact_message])
    @user = User.find(params[:id])
    
    respond_to do |format|
      if @message.valid?
        UserMailer.delay.user_contact_mail(@user, @message)
        format.html { redirect_to(user_path(@user), :notice => "Your message was successfully sent.") }
        format.js { redirect_to(user_path(@user), :notice => "Your message was successfully sent.") }
      else
        format.html { render "_contact" }
        format.js { render "_contact", :layout => false, :status => 403 }
      end
    end
    
  end
  
  def import
    if params[:file].present?
       infile = params[:file].read 
       n, errs = 0, [] 
       
       CSV.parse(infile) do |row| 
         n += 1 
         # SKIP: header i.e. first row OR blank row 
         next if n == 1 or row.join.blank?
         user = User.new(:email => row[0])  
         if !user.auto_create_user # try to create new user, otherwise collect error records to export
           row << user.errors.full_messages.first
           errs << row 
         end 
       end 
     # Export Error file for later upload upon correction 
      if errs.any? 
         err_file = "errors_#{Date.today.strftime('%d%b%y')}.csv" 
         errs.insert(0, ["email", "error"]) 
         err_csv = CSV.generate do |csv| 
           errs.each {|row| csv << row} 
         end 
         send_data err_csv, 
          :type => 'text/csv; charset=iso-8859-1; header=present', 
          :disposition => "attachment; filename=#{err_file}"
       else 
          redirect_to add_users_management_index_path, notice: "Users successfully uploaded!"
       end
    end
  end
  
end
