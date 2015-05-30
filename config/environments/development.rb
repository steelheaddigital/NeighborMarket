NeighborMarket::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb
  
  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  config.eager_load = false

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
    :port                 => ENV["SMTP_PORT"],
    :domain               => ENV["SMTP_DOMAIN"],
    :user_name            => ENV["SMTP_USERNAME"],
    :password             => ENV["SMTP_PASSWORD"],
    :authentication       => ENV["SMTP_AUTHENTICATION"],
    :enable_starttls_auto => true
  }
  
  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Expands the lines which load the assets
  config.assets.debug = true
  
  Paperclip.options[:command_path] = "/usr/local/bin/"
  
  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true
  
  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
end
