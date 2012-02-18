class UsersController < ApplicationController
#  load_and_authorize_resource :class => UsersController
  
  def show
    @user = User.find(params[:id])
    authorize! :show, @user
  end

  def approve_seller
    user = User.find(params[:id])
    user.seller.update_attributes(:approved => true)
    redirect_to management_index_url, :notice => "Seller successfully approved!"
    
    authorize! :manage, user.seller
  end
end
