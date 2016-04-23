class ActivitiesController < ApplicationController
	
	def create
		
	end

	def destroy
		@user = User.find(params[:user_id])
		@activity = @user.activities.find(params[:id])
		@activity.destroy

		redirect_to root_path(@user)
	end
	
end
