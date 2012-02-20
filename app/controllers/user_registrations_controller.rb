class UserRegistrationsController < Devise::RegistrationsController
  
  def new
    resource = build_resource({})
    respond_with resource
    
    authorize! :manage, :manager if params[:user][:user_type] == "manager"
    
  end
  
  def create
    build_resource

    # customized code begin

    # create a new child instance depending on the given user type
    child_class = params[:user][:user_type].camelize.constantize
    resource_role = resource.roles.new
    resource_role.rolable = child_class.new(params[child_class.to_s.underscore.to_sym])
    
    # first check if child instance is valid
    # cause if so and the parent instance is valid as well
    # it's all being saved at once
    valid = resource.valid?
    valid = resource_role.rolable.valid? && valid

    # customized code end

    if valid && resource.save    # customized code
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
        respond_with resource, :location => redirect_location(resource_name, resource)
      else
        set_flash_message :notice, :inactive_signed_up, :reason => inactive_reason(resource) if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords(resource)
      respond_with_navigational(resource) { render_with_scope :new }
    end
  end
  
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    
    # customized code begin
    
    role_ids = params[:user][:role_id]
    role_ids.each do |id|
      role = resource.roles.find(id)
      target_rolable = role.rolable
      target_rolable_type = role.rolable_type.camelize.constantize
      rolable_type_params = params[target_rolable_type.to_s.underscore.to_sym]
      
      unless rolable_type_params.nil?
        rolable_type_params.keys.each do |key|
          attribute_to_update = key.to_s.underscore.to_sym
          target_rolable.update_attributes attribute_to_update => rolable_type_params[attribute_to_update]
        end
      end
    end
    
    
    # customized code end
    
    if resource.update_with_password(params[resource_name])
      if is_navigational_format?
        if resource.respond_to?(:pending_reconfirmation?) && resource.pending_reconfirmation?
          flash_key = :update_needs_confirmation
        end
        set_flash_message :notice, flash_key || :updated
      end
      sign_in resource_name, resource, :bypass => true
      respond_with resource, :location => after_update_path_for(resource)
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  def inactive_signup
    
  end
  
  #Override the devise imethod to send new sellers to a custom page
  def after_inactive_sign_up_path_for(resource)
    users_inactive_signup_path
  end
  
end
