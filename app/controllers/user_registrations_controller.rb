class UserRegistrationsController < Devise::RegistrationsController
  prepend_before_filter :require_no_authentication, :only => [ :new, :create, :cancel ]
  prepend_before_filter :authenticate_scope!, :only => [:become_seller, :become_buyer, :edit, :update, :destroy]
  
  def new
    resource = build_resource({})
    add_resource_role(resource)

    respond_with resource
    
    authorize! :manage, :manager if params[:user][:user_type] == "manager"
    
  end
  
  def create
    build_resource
    
    add_resource_role(resource)
    
    valid = resource.valid?

    if valid && resource.save    # customized code
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        if resource.role?("seller")
          user = User.find(resource.id)
          send_new_seller_email(user)
        end
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords(resource)
      respond_with resource
    end
  end
  
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    if params[:user][:become_seller] == "true"
      resource.become_seller = true
      add_role(resource, "seller")
    end
    if params[:user][:become_buyer] == "true"
      resource.become_buyer = true
      add_role(resource, "buyer")
    end
    if resource.update_with_password(params[resource_name])
      if is_navigational_format?
        if resource.respond_to?(:pending_reconfirmation?) && resource.pending_reconfirmation?
          flash_key = :update_needs_confirmation
        end
        # customized code begin
        if params[:user][:become_seller] == "true"
          set_flash_message :notice, flash_key || :became_seller
          send_new_seller_email(resource)
        else
          set_flash_message :notice, flash_key || :updated
        end
        # customized code end
      end
      sign_in resource_name, resource, :bypass => true
      respond_with resource, :location => after_update_path_for(resource)
    else
      clean_up_passwords resource
      respond_with_navigational(resource) do
        if params[:user][:become_seller] == "true"
          render :become_seller
        else
          respond_with resource
        end
      end
    end
  end

  def seller_inactive_signup
  end
  
  def inactive_signup
  end
  
  private
  
  #Override the devise method to send new sellers to a custom page
  def after_inactive_sign_up_path_for(resource)
    if resource.seller?
      user_seller_inactive_signup_path 
    else
      user_inactive_signup_path
    end
  end
  
  def become_seller
    add_role(resource, "seller")
  end
  
  def become_buyer
    add_role(resource, "buyer")
  end
  
  def send_new_seller_email(user)
     managers = Role.find_by_name("manager").users 
      managers.each do |manager|
        ManagerMailer.delay.new_seller_mail(user, manager)
      end
  end
  
  def add_resource_role(resource)
    if params[:user][:user_type].downcase == "buyer"
      add_role(resource, "buyer")
    end
    if params[:user][:user_type].downcase == "seller"
      add_role(resource, "seller")
    end
  end
  
  def add_role(resource, role)
      new_role = Role.new
      new_role.name = role.downcase
      resource.roles.build(new_role.attributes)
  end
  
end
