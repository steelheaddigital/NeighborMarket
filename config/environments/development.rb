NeighborMarket::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb
  
  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  config.cache_store = :dalli_store

  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = false
  config.action_mailer.default_url_options = { :host => ENV["HOST"] }
  ActionMailer::Base.default :from => ENV["DEFAULT_FROM"]
  config.action_mailer.smtp_settings = {
    :address              => ENV["SMTP_ADDRESS"],
    :port                 => 587,
    :domain               => ENV["SMTP_DOMAIN"],
    :user_name            => ENV["SMTP_USERNAME"],
    :password             => ENV["SMTP_PASSWORD"],
    :authentication       => "plain",
    :enable_starttls_auto => true
  }
  
  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true
  
  Paperclip.options[:command_path] = "/usr/local/bin/"
  
  config.less.compress = false
end
