class UserMailer < ActionMailer::Base
  default from: "admin@steelheaddigital.com"
  
  def user_contact_mail(user, message)
    @message = message
    mail( :to => user.email,
          :reply_to => message.email,
          :subject => "Neighbor Market - #{message.subject}")
  end
  
end
