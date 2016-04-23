class User < ActiveRecord::Base

	has_many :activities, dependent: :destroy
	has_many :friends, dependent: :destroy
	has_many :followers, dependent: :destroy
	has_many :tweets, dependent: :destroy
	has_many :relationships, dependent: :destroy

	def self.sign_in_from_omniauth(auth)
		find_by(provider: auth['provider'], uid: auth['uid']) || create_user_from_omniauth(auth)
		
	end

	def self.create_user_from_omniauth(auth)
		create(
			provider: auth['provider'],
			uid: auth['uid'],
			name: auth['info']['name'],
			screen_name: auth['info']['screen_name'],
			email: auth['info']['email'],
			picture: auth['info']['image'],
			oauth_token: auth['credentials']['token'],
			oauth_secret: auth['credentials']['secret'],
			first_time: true
		)
	end

	def facebook
		@facebook ||= Koala::Facebook::API.new(oauth_token)
		block_given? ? yield(@facebook) : @facebook
	rescue Koala::Facebook::APIError => e
		logger.info e.to_s
		nil
	end

	def twitter
		@client ||= Twitter::REST::Client.new do |config|
			config.consumer_key        = "ffPavT3CVp1JJuS7oxw9xZPxb"
		  	config.consumer_secret     = "e9Lm6o2MOIUPobNeiAV1G0hZXq6lMFNFihA8so4nYeML3nWY2p"
		  	config.access_token        = oauth_token
		  	config.access_token_secret = oauth_secret
		end
	end

	def self.fb_data(user)
		client = user.facebook

		begin

			posts = client.get_connections('me', 'posts', { fields: ['id', 'message', 'message_tags',
																	'from', 'type', 'link', 'created_time'] })
			friends = client.get_connections('me', 'friends')
			#mentions = client.get_connections('me', 'tagged')
		rescue
			
			p "There was an error while trying to authenticate you..."

		end

		friends.each do |friend|
			Friend.set_fb_friend(user, friend)
		end

		posts.each do |post|
			if post['message_tags']
				tags = post['message_tags']
				tags.each do |tag|
					friend = Friend.where(fid: tag[1][0]['id'])
					Activity.set_fb_activity(user, post, friend.first) if friend.size > 0
				end
			end
		end
		
		relationship(user)
	end

	def self.tw_data(user)
		
		client = user.twitter

		begin

			tweets = client.user_timeline(count: 150, include_rts: false) # Trae los últimos 150 tweets del usuario
			mentions = client.mentions_timeline
			my_retweets = client.retweeted_by_me
			retweets_of_me = client.retweets_of_me
			
			if user.first_time
				followers = fetch_all_followers(user, client) # Trae todos los seguidores del usuario
				friends = fetch_all_friends(user, client) # Trae todas las cuentas que sigue el usuario
			else
				followers = client.followers
				friends = client.friends

				followers.each do |f|
					Follower.set_follower(user, f)
				end

				friends.each do |f|
					Friend.set_tw_friend(user, f)
				end
			end
		
		rescue Twitter::Error::TooManyRequests => error

			sleep error.rate_limit.reset_in + 1
			p "Twitter::Error::TooManyRequests"

		end

		#followers.each do |follower|
		#	Friend.set_tw_friend(user, follower) if follower.following?
		#end

		my_retweets.each do |retweet|
			fid = retweet.user_mentions.first.id
			Tweet.set_tweet(user, retweet, fid, "Retweet")
		end

		mentions.each do |mention|
			fid = mention.user.id
			Tweet.set_tweet(user, mention, fid, "Mentioned")
		end

		tweets.each do |tweet|
			if tweet.user_mentions
				mentions = tweet.user_mentions
				mentions.each do |mention|
					Tweet.set_tweet(user, tweet, mention.id.to_s)
				end
			end
	    end

	    user.friends.each do |friend|
	    	if (amount = user.tweets.where(tweet_type: "Mention", friend: friend.fid).size) > 0
	    		Activity.set_tw_activity(user, friend.fid, amount, "Mention")
	    	end

	    	if (amount = user.tweets.where(tweet_type: "Mentioned", friend: friend.fid).size) > 0	    		
	    		Activity.set_tw_activity(user, friend.fid, amount, "Mentioned")
	    	end
	    	
	    	if (amount = user.tweets.where(tweet_type: "Retweet", friend: friend.fid).size) > 0
	    		Activity.set_tw_activity(user, friend.fid, amount, "Retweet")
	    	end
	    end

		relationship(user)
		user.update(first_time: false)
	end

	def self.relationship(user)
		user.friends.each do |friend|
			amount = user.tweets.where(friend: friend.fid).size
=begin
			if a.size >= b.size
				rate = Activity.rate(a.size, b.size)
			else
				rate = Activity.rate(b.size, a.size)
			end
=end
			Relationship.set_relationship(amount, user, friend) if amount > 0
		end
	end

	SLICE_SIZE = 100
	
	def self.fetch_all_friends(user, client)
		client.friend_ids(user.screen_name).each_slice(SLICE_SIZE).with_index do |slice, i|
			client.users(slice).each_with_index do |f, j|
				Friend.set_tw_friend(user, f)
		  	end
		end
	end

	def self.fetch_all_followers(user, client)
		client.follower_ids(user.screen_name).each_slice(SLICE_SIZE).with_index do |slice, i|
			client.users(slice).each_with_index do |f, j|
				Follower.set_follower(user, f)
		  	end
		end
	end

	def self.update_data
		users = User.all

		users.each do |user|
			if user.provider == 'facebook'
				fb_data(user)
			else
				tw_data(user)
			end
		end
	end
end