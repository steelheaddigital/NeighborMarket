class ManagerMailer < ActionMailer::Base
  default from: "tom@steelheaddigital.com"
  
  def new_seller_mail(user)
    @user = user
    
    managers = Role.find_all_by_rolable_type("Manager")
    managers.each do |manager|
      manager_user = User.find(manager.user_id)
      mail(:to => manager_user.email, :subject => "New seller has signed up at the Garden Marketplace - Pending Verification" )
    end
    
  end
end
