class UserConfirmationsController < Devise::ConfirmationsController
  
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      if resource.seller? && !resource.approved_seller?
        set_flash_message(:notice, :confirmed_but_not_approved)
        respond_with_navigational(resource){ redirect_to root_path }
      else
        set_flash_message(:notice, :confirmed) if is_navigational_format?
        sign_in(resource_name, resource)
        respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
      end
    else
      respond_with_navigational(resource.errors, :status => :unprocessable_entity){ render :new }
    end
  end
  
  def auto_create_confirmation
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    
    if resource.errors.empty?
      set_flash_message(:notice, :auto_create_confirmed) if is_navigational_format?
      sign_in(resource_name, resource)
      respond_with_navigational(resource){ redirect_to edit_user_registration_path(:auto_create_update => "true") }
    else
      respond_with_navigational(resource.errors, :status => :unprocessable_entity){ render :new }
    end
    
  end
  
end