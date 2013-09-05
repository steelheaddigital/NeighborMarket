NeighborMarket::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  app_config = YAML.load_file("#{Rails.root}/config/main_conf.yml")

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true


  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
  
  #configure mail settings
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.default_url_options = { :host => app_config['production']["host"] }
  ActionMailer::Base.default :from => app_config['production']["default_from"]
  config.action_mailer.smtp_settings = {
    :address              => app_config['production']['smtp_settings']['address'],
    :port                 => app_config['production']['smtp_settings']['port'],
    :domain               => app_config['production']['smtp_settings']['domain'],
    :user_name            => app_config['production']['smtp_settings']['user_name'],
    :password             => app_config['production']['smtp_settings']['password'],
    :authentication       => app_config['production']['smtp_settings']['authentication'],
    :enable_starttls_auto => app_config['production']['smtp_settings']['enable_starttls_auto'],
    :openssl_verify_mode  => app_config['production']['smtp_settings']['openssl_verify_mode']
  }
  
  Paperclip.options[:command_path] = "/usr/bin/"
  
  config.paperclip_defaults = {
    :storage => :s3,
    :s3_credentials => {
      :bucket => ENV['AWS_BUCKET'],
      :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
    }
  }
  
  config.less.compress = true
end
