class UsersController < ApplicationController
  load_and_authorize_resource
  
  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
    authorize! :manage, @user
    
    #if the view is being loaded via ajax, don't render the layout
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
        
        format.html { redirect_to management_index_path, notice: 'User successfully updated!'}
        format.js { render :nothing => true }
      else
        format.html { render "new" }
        format.js { render :edit, :layout => false }
      end
    end
  
  end

end
