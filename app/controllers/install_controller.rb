class InstallController <  ActionController::Base
  protect_from_forgery
  
  def index
     respond_to do |format|
       format.html
     end
  end
  
  def install
    @errors = Array.new
    result = false
    
    begin
      `touch tmp/restart.txt`
      db_output = `rake db:setup RAILS_ENV=#{Rails.env}` ; result=$?.success?
      if result
         whenever_output = `whenever -w -s 'environment=#{Rails.env}'` ; result=$?.success?
         create_manager if result
         @errors << whenever_output if !result
      else
        @errors << db_output
      end
    rescue Exception => e
      result = false
      @errors << e.message
    ensure
      respond_to do |format|
        if result
          format.html {render :success}
        else
          format.html {render :error}
        end
      end
    end
  end
  
  private
  
  def create_manager
    env = Rails.env
    app_config = YAML::load(File.open("config/main_conf.yml"))
    manager_email = app_config["#{env}"]['manager_email']
    
    User.delete_all
    user = User.new(
      :email => manager_email,
      :skip_confirmation_email => true
    )
    user.add_role('manager')
    if user.auto_create_user
      UserMailer.manager_install_mail(user).deliver
    end
  end
  
end
