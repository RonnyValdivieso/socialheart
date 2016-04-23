class Relationship < ActiveRecord::Base
	belongs_to :user
	belongs_to :friend

	def self.set_relationship(total, user, friend)
		user.relationships.find_by(friend: friend) || create_relationship(total, user, friend)
	end

	def self.create_relationship(total, user, friend)
		create(
			uid: user.uid,
			fid: friend.fid,
			level: total,
			user: user,
			friend: friend
		)
	end
end
