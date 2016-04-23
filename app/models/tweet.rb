class Tweet < ActiveRecord::Base
	belongs_to :user

	def self.set_tweet(user, t, friend, type = "Mention")
		user.tweets.find_by(tid: t.id) || create_tweet(user, t, friend, type)
	end

	def self.create_tweet(user, t, friend, type)
		user.tweets.create(
			tid: t.id,
			friend: friend,
			tweet_type: type,
			text: t.text,
			created_at: t.created_at,		
			geo: t.geo,
			place: t.place
		)
	end
end