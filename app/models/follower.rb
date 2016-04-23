class Follower < ActiveRecord::Base
	belongs_to :user

	def self.set_follower(user, follower)
		user.followers.find_by(fid: follower.id) || create_follower(user, follower)
	end

	def self.create_follower(user, follower)
		user.followers.create(
			fid: follower.id,
			name: follower.name,
			screen_name: follower.screen_name,
			location: follower.location,
			following: follower.following
		)
	end
end
