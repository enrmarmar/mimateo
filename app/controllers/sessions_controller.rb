class SessionsController < ApplicationController
	skip_before_filter :set_current_user

	def index
	end

	def create
		auth = request.env["omniauth.auth"]
		if auth.error
			flash[:warning] = "Error de acceso: " + params[:message]
			redirect_to '/index' and return
		end
		user = User.find_by_provider_and_uid(auth["provider"], auth["uid"]) || User.create_with_omniauth(auth)
		session[:user_id] = user.id
		redirect_to tasks_path and return
	end

	def failure
		flash[:warning] = "Error de acceso: " + params[:message]
		redirect_to '/index' and return
	end

	def login
		if user = User.authenticate(params[:login])
			session[:user_id] = user.id
		end	
		redirect_to tasks_path
	end

	# Only for development
	def login_as_1
		id_1 = User.find_by_email('ana@prueba.es')
		session[:user_id] = id_1
		redirect_to tasks_path
	end

	# Only for development
	def login_as_2
		id_2 = User.find_by_email('pedro@prueba.es')
		session[:user_id] = id_2
		redirect_to tasks_path
	end

	# Only for development
	def login_as_3
		id_3 = User.find_by_email('ramon@prueba.es')
		session[:user_id] = id_3
		redirect_to tasks_path
	end

	# Only for development
	def login_as_4
		id_4 = User.find_by_email('isabel@prueba.es')
		session[:user_id] = id_4
		redirect_to tasks_path
	end

	def destroy
		session.delete(:user_id)
		flash[:notice] = 'Desconectado'
		redirect_to tasks_path
	end
end
