Rails.application.config.middleware.use OmniAuth::Builder do
  #provider :google_oauth2, '454168980577', 'QNuBPc6b5Sh-ew_2Nh0u6ZWz',
  provider :google_oauth2, '282259666783', 'Q7BHN-SDm5m1Buck_S_01QCq',
  	{
    	:scope => "userinfo.email,userinfo.profile,plus.me",
    	:force_login => true,
    	:approval_prompt => "auto"
  	}
end