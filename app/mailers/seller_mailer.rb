class SellerMailer < ActionMailer::Base
  default from: "admin@steelheaddigital.com"

  def seller_approved_mail(user)
    mail(:to => user.email, :subject => "Your Neighbor Market Seller Account Is Approved" )
  end
end
