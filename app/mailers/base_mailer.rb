class BaseMailer < ActionMailer::Base
  helper :application
  
  def initialize *args
    super(*args)
    Time.zone = SiteSetting.first.time_zone if SiteSetting.first
  end
end
