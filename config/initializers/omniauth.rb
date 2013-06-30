Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, '454168980577', 'QNuBPc6b5Sh-ew_2Nh0u6ZWz',
  	{
    	:scope => "userinfo.email,userinfo.profile,plus.me",
    	:force_login => true,
    	:approval_prompt => "auto"
  	}
end