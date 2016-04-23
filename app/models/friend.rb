class Friend < ActiveRecord::Base

	belongs_to :user

	has_many :relationships, dependent: :destroy

	#Set friends for facebook users
	def self.set_fb_friend(user, friend)
		user.friends.find_by(fid: friend['id']) || create_fb_friend(user, friend)
	end

	def self.create_fb_friend(user, friend)
		user.friends.create(
			fid: friend['id'],
			name: friend['name'],
			location: friend['location']
		)
	end

	#Set friends for twitter users
	def self.set_tw_friend(user, friend)
		user.friends.find_by(fid: friend.id) || create_tw_friend(user, friend)
	end

	def self.create_tw_friend(user, friend)
		user.friends.create(
			fid: friend.id,
			name: friend.name,
			location: friend.location
		)
	end

end
