class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
  end

  def approve_seller
    user = User.find(params[:id])
    user.seller.update_attributes(:approved => true)
    redirect_to management_index_url
  end
end
