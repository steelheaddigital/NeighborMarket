class ManagerMailer < ActionMailer::Base
  default :from => "admin@steelheaddigital.com"
  
  def new_seller_mail(user, manager)
    @user = user
    @site_settings = SiteSetting.first
    mail( :to => manager.email, 
          :subject => "New seller has signed up at #{@site_settings.site_name} - Pending Verification" )
  end
end
