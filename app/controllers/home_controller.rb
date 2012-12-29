class HomeController < ApplicationController
  def index
    if SiteSetting.first
      @site_name = SiteSetting.first.site_name
    else
      @site_name = "Neighbor Market"
    end
  end
  
  def refresh
    render :text => "site successfully refreshed \n"
  end

end
