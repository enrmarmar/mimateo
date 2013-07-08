Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['OAUTH_CLIENT_ID'], ENV['OAUTH_CLIENT_SECRET'],
  	{
    	:scope => "userinfo.email,userinfo.profile,plus.me,calendar",
    	:force_login => true,
  	}

  OmniAuth.config.on_failure = UsersController.action(:failure)
end