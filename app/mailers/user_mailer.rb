class UserMailer < BaseMailer
  
  def user_contact_mail(user, message)
    @message = message
    site_settings = SiteSetting.first
    mail( :to => user.email,
          :reply_to => message.email,
          :subject => "#{site_settings.site_name} - #{message.subject}")
  end
  
end
