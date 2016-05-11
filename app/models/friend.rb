class Friend < ActiveRecord::Base

	belongs_to :user

	has_many :relationships, dependent: :destroy

	def self.set_friend(user, friend)
		user.friends.find_by(fid: friend['id']) || create_friend(user, friend)
	end

	def self.create_friend(user, friend)
		user.friends.create(
			fid: friend['id'],
			name: friend['name'],
			location: friend['location']
		)
	end

end
