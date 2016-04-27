OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
	provider :developer unless Rails.env.production?
  	provider :facebook, '1498966967094943', '501f463dae2f251f641d590cdd3ea402',
  		   #:scope => 'email, user_friends, user_posts, publish_actions',
  		   :display => 'popup'
  	
  	provider :twitter, 'ffPavT3CVp1JJuS7oxw9xZPxb', 'e9Lm6o2MOIUPobNeiAV1G0hZXq6lMFNFihA8so4nYeML3nWY2p'
end