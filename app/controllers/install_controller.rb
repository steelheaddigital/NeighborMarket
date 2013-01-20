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
      db_output = `rake db:setup RAILS_ENV=#{Rails.env}` ; result=$?.success?
      if result
         whenever_output = `whenever -w -s 'environment=#{Rails.env}'` ; result=$?.success?
         @errors << whenever_output if !result
      else
        @errors << db_output
      end
    rescue Exception => e
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
  
end
