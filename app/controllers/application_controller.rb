# encoding: UTF-8

class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_current_user
  after_filter :flash_to_headers

  helper_method :current_user
  helper_method :user_signed_in?
  helper_method :correct_user?

  def set_current_user
  	@current_user ||= User.find_by_id(session[:user_id])
  	if @current_user
  		@sideTasks = @current_user.active_tasks
    	@sideContacts = @current_user.active_contacts
      # TODO: store these numbers in User model to improve performance
      @bones_given = @current_user.given_bones.sum(:amount)
      @bones_taken = @current_user.taken_bones.sum(:amount)
      @current_user.last_logged_in = Time.now
      @current_user.save
  	else
      flash[:notice] = "Debe ingresar como usuario/a para utilizar Mi Mateo"
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
    response.headers['X-Message-Type'] = flash_type.to_s
    response.headers['Reload'] = "true" if flash[:reload]
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

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def user_signed_in?
    return true if current_user
  end

  def correct_user?
    @user = User.find(params[:id])
    unless current_user == @user
      redirect_to root_url, :alert => "Access denied."
    end
  end

  def authenticate_user!
    if !current_user
      redirect_to root_url, :alert => 'You need to sign in for access to this page.'
    end
  end

end