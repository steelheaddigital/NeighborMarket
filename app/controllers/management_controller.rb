class ManagementController < ApplicationController
  def index
    @sellers = Seller.find_all_by_approved(false)
  end
end
