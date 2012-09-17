class BaseMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)
  default from: "admin@steelheaddigital.com"
  
  def initialize *args
    super(*args)
    Time.zone = SiteSetting.first.time_zone if SiteSetting.first
  end
end
