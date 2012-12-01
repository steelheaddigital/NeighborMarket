class SiteSettingController < ApplicationController
  load_and_authorize_resource
  
  def edit
    @site_settings = SiteSetting.first ? SiteSetting.first : SiteSetting.new
    
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  def update
    @site_settings = SiteSetting.new_setting(params[:site_setting])
    
    respond_to do |format|
      if @site_settings.save
        format.html { redirect_to edit_site_setting_index_path, notice: 'Site Settings Successfully Saved!'}
        format.js { render :nothing => true }
      else
        format.html { render :edit }
        format.js { render :edit, :layout => false, :status => 403 }
      end
    end
  end
  
end