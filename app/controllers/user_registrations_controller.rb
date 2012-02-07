class UserRegistrationsController < Devise::RegistrationsController
  def create
    build_resource

    # customized code begin

    # crate a new child instance depending on the given user type
    child_class = params[:user][:user_type].camelize.constantize
    resource.rolable = child_class.new(params[child_class.to_s.underscore.to_sym])

    # first check if child instance is valid
    # cause if so and the parent instance is valid as well
    # it's all being saved at once
    valid = resource.valid?
    valid = resource.rolable.valid? && valid

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
end
