class Activity < ActiveRecord::Base
	
	belongs_to :user

	#Set activity for twitter users
	def self.set_activity(user, friend, amount, type)
		user.activities.find_by(friend: friend, activity_type: type) || create_activity(user, friend, amount, type)
	end
	
	def self.create_activity(user, friend, amount, type)
		user.activities.create(
			friend: friend,
			activity_type: type,
			level: amount
		)
	end
end