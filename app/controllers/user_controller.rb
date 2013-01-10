class UserController < ApplicationController
  require 'csv'
  load_and_authorize_resource
  skip_authorize_resource :only => [:public_show, :contact]
  
  def show
    @user = User.find(params[:id])
  end

  def public_show
    @user = User.find(params[:id])
    @message = UserContactMessage.new
    
    respond_to do |format|
      
      format.html
      format.js { render :layout => false }
    end
  end
  
  def new
    @user = User.new
    
    respond_to do |format|
      format.html {render :partial => "new"}
      format.js { render :partial => "new", :layout => false }
    end
  end
  
  def create
    @user = User.new(params[:user])
    respond_to do |format|
      if @user.auto_create_user
        format.html { redirect_to add_users_management_index_path, notice: 'User successfully created!'}
        format.js { redirect_to add_users_management_index_path }
      else
        format.html { render 'management/add_users', :layout => 'management' }
        format.js { render 'management/add_users', :layout => false, :status => 403 }
      end
    end
  end
  
  def edit
    @user = User.find(params[:id])
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def update
    @user = User.find(params[:id])
    previous_seller_approved = @user.approved_seller?
    
    respond_to do |format|
      if @user.update_attributes(params[:user])
        
        new_seller_approved = @user.approved_seller?
        
        if(previous_seller_approved == false && new_seller_approved == true)
          SellerMailer.seller_approved_mail(@user).deliver
        end
        
        format.html { redirect_to user_search_management_index_path, notice: 'User successfully updated!'}
        format.js { render :nothing => true }
      else
        format.html { render :edit }
        format.js { render :edit, :layout => false }
      end
    end
  
  end
  
  def contact
    @message = UserContactMessage.new(params[:user_contact_message])
    user = User.find(params[:id])
    
    if @message.valid?
      UserMailer.user_contact_mail(user, @message).deliver
      redirect_to(public_show_user_path(user), :notice => "Your message was successfully sent.")
    else
      flash.now.alert = "Please fill all fields."
      render :public_show
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
