class Api::V1::BaseController < ActionController::Metal
  include ActionController::Rendering        # enables rendering
  include ActionController::MimeResponds     # enables serving different content types like :xml or :json
  include AbstractController::Callbacks      # callbacks for your authentication logic

  append_view_path "#{Rails.root}/app/views" # you have to specify your views location as wellend

  before_filter :set_current_user

  def set_current_user
  	Rails.logger.debug("Token received : " + params[:token])
  	Rails.logger.debug("Real token : " + ENV['ANDROID_APP_SECRET_TOKEN'])
  	if params[:token] == ENV['ANDROID_APP_SECRET_TOKEN']
  		Rails.logger.debug("Token accepted")
  		@current_user = User.find_by_email(params[:email])
  		Rails.logger.debug("@current_user = " + @current_user.email)
  	end
  end

end