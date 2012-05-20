class ManagerMailer < ActionMailer::Base
  default :from => "admin@steelheaddigital.com"
  
  def new_seller_mail(user, manager)
    @user = user
    mail( :to => manager.email, 
          :subject => "New seller has signed up at the Neighbor Market - Pending Verification" )
  end
end
