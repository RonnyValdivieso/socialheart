class SessionsController < ApplicationController
	def create
		auth = request.env["omniauth.auth"]
		session[:omniauth] = auth.except('extra')
		user = User.sign_in_from_omniauth(auth)
		user.update(oauth_token: auth['credentials']['token'])
		session[:user_id] = user.id

		if user.first_time == true
			if user.provider == 'facebook'
				User.fb_data(user)
			else
				User.tw_data(user)
			end
			user.update(first_time: false)
		end

		redirect_to root_url, notice: "SIGNED IN"
	end

	def destroy
		session[:user_id] = nil
		session[:omniauth] = nil
		redirect_to root_url, notice: "SIGNED OUT"
	end
	
end