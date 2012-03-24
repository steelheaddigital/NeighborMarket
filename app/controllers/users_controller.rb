class UsersController < ApplicationController
  
  def show
    @user = User.find(params[:id])
    authorize! :manage, @user
  end

  def edit
    @user = User.find(params[:id])
    authorize! :manage, @user
    
    #if the view is being loaded via ajax, don't render the layout
    respond_to do |format|
      format.js { render :layout => false }
    end
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = "Successfully updated User."
      redirect_to management_index_url
    else
      render :action => 'edit'
    end
    
    authorize! :manage, @user
  end
  
  def approve_seller
    user = User.find(params[:id])
    role = user.roles.find_by_rolable_type("Seller")
    if role.seller.update_attributes(:approved => true)
      SellerMailer.seller_approved_mail(user).deliver
      redirect_to management_index_url, :notice => "Seller successfully approved!"
    end
    authorize! :manage, User
  end
end
