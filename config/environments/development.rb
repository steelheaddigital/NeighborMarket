NeighborMarket::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  app_config = YAML.load_file("#{Rails.root}/config/main_conf.yml")
  
  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.default_url_options = { :host => app_config['development']["host"] }
  ActionMailer::Base.default :from => app_config['development']["default_from"]
  config.action_mailer.smtp_settings = {
    :address              => app_config['development']['smtp_settings']['address'],
    :port                 => app_config['development']['smtp_settings']['port'],
    :domain               => app_config['development']['smtp_settings']['domain'],
    :user_name            => app_config['development']['smtp_settings']['user_name'],
    :password             => app_config['development']['smtp_settings']['password'],
    :authentication       => app_config['development']['smtp_settings']['authentication'],
    :enable_starttls_auto => app_config['development']['smtp_settings']['enable_starttls_auto'],
    :openssl_verify_mode  => app_config['development']['smtp_settings']['openssl_verify_mode']
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
end
