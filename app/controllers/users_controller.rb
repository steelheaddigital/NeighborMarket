class UsersController < ApplicationController
  
  def show
    @user = User.find(params[:id])
    authorize! :show, @user
  end

  def approve_seller
    user = User.find(params[:id])
    role = user.roles.find_by_rolable_type("Seller")
    role.seller.update_attributes(:approved => true)
    redirect_to management_index_url, :notice => "Seller successfully approved!"
    
    authorize! :manage, Seller
  end
end
