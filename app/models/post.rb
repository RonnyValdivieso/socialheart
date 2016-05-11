class Post < ActiveRecord::Base
	belongs_to :user

	def self.set_post(user, post, friend, type)
		user.posts.find_by(pid: post['id']) || create_post(user, post, friend, type)
	end

	def self.create_post(user, post, friend, type)
		user.posts.create(
			pid: post['id'],
			friend: friend,
			post_type: type,
			text: post['text'] || post['message'],
			created_at: post['created_at'] || post['created_time']
		)
	end
end
