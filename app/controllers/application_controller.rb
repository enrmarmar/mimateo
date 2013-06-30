class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_current_user
  after_filter :flash_to_headers

  def set_current_user
  	@current_user ||= User.find_by_id(session[:user_id])
  	if @current_user
      # to_a avoids "can't convert nil into Array" when no active_invited_tasks
  		@sideTasks = @current_user.tasks + @current_user.active_invited_tasks.to_a
    	@sideContacts = @current_user.active_contacts
      # TODO: store these numbers in User model to improve performance
      @bones_given = @current_user.given_bones.sum(:amount)
      @bones_taken = @current_user.taken_bones.sum(:amount)
  	else
      flash[:notice] = "Debe ingresar como usuario para utilizar Mi Mateo"
      redirect_to '/index' and return
  	end
  end

  def access_denied
    flash[:warning] = "Acceso denegado."
    if request.xhr?
      render :nothing => true
    else
      redirect_to :back
    end
  end

  def flash_to_headers
    return unless request.xhr?
    # TODO: Fix utf-8 encoding in AJAX
    response.headers['Content-Type'] = "text/html; charset=utf-8"
    response.headers['X-Message'] = flash_message
    response.headers["X-Message-Type"] = flash_type.to_s
    flash.discard
  end

  private

  def flash_message
    [:error, :warning, :notice].each do |type|
      return flash[type] unless flash[type].blank?
    end
    # if we don't return something here, the above code will return "error, warning, notice"
    return ''
  end

  def flash_type
    [:error, :warning, :notice].each do |type|
      return type unless flash[type].blank?
    end
  end

end