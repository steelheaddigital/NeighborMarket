class UserMailer < BaseMailer
  
  def user_contact_mail(user, message)
    @message = message
    site_settings = SiteSetting.first
    mail( :to => user.email,
          :reply_to => message.email,
          :subject => "#{site_settings.site_name} - #{message.subject}")
  end
  
  def auto_create_user_mail(user)
    site_settings = SiteSetting.first
    @user = user
    mail( :to => user.email, 
          :subject => "The manager at #{site_settings.site_name} has created a new account for you")
  end
  
  def manager_install_mail(user)
    @user = user
    mail( :to => user.email, 
          :subject => "Your Neighbor Market site has been installed. Confirm your Manager account now.")
  end
  
end
