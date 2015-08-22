class BuyerMailerPreview < ActionMailer::Preview
  def reccomendation_mail
    buyer = User.first
    BuyerMailer.reccomendation_mail(buyer)
  end
end
