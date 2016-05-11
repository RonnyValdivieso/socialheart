class User < ActiveRecord::Base

	has_many :activities, dependent: :destroy
	has_many :friends, dependent: :destroy
	has_many :followers, dependent: :destroy
	has_many :posts, dependent: :destroy
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

			posts = client.get_connections('me', 'posts', { fields: ['id', 'message', 'message_tags', 'story_tags',
																	'type', 'link', 'created_time'] })
			friends = client.get_connections('me', 'friends')
			mentions = client.get_connections('me', 'tagged', { fields: ['id', 'message', 'created_time',
																		'from']})
		rescue
			
			p "There was an error while trying to authenticate you..."

		end

		friends.each do |friend|
			Friend.set_friend(user, friend)
		end

		posts.each do |post|
			if post['message_tags']
				tags = post['message_tags']
				tags.each do |tag|
					fb_friend(client, user, tag[1][0]['id'], post, "Mention")
				end
			end
=begin
			if post['story_tags']
				tags = post['story_tags']
				tags.each do |tag|
					fb_friend(client, user, tag[1][0]['id'], post, "Mention") if tag[1][0]['id'] != user.uid
				end
			end
=end
		end

		mentions.each do |mention|
			fb_friend(client, user, mention['from']['id'], mention, "Mentioned")
		end

		activity_relationship(user)
	end

	def self.tw_data(user)
		
		client = user.twitter

		begin

			tweets = client.user_timeline(count: 150, include_rts: false)	# Trae los últimos 150 tweets del usuario, excepto retweets
			mentions = client.mentions_timeline(count: 150)					# Trae las últimas 150 menciones por parte del usuario
			my_retweets = client.retweeted_by_me(count: 150)				# Trae los últimos 150 retweets del usuario
			retweets_of_me = client.retweets_of_me
			
			if user.first_time		# Si el usuario inicia sesión por primera vez
				followers = fetch_all_followers(user, client)	# Trae --> seguidores del usuario
				friends = fetch_all_friends(user, client)		# Trae --> a quienes sigue el usuario
			else
				followers = client.followers					# Trae --> seguidores del usuario (últimos 20)
				friends = client.friends						# Trae --> a quienes sigue el usuario (últimos 20)

				followers.each do |f|
					Follower.set_follower(user, f)				# Guarda --> seguidores en la base de datos
				end

				friends.each do |f|
					Friend.set_friend(user, f)					# Guarda --> a quienes sigue el usuario
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
			if retweet.user_mentions.size > 0
				fid = retweet.user_mentions.first.id
				Post.set_post(user, retweet, fid, "Retweet")		# Guarda --> retweets que ha hecho el usuario
			end
		end

		mentions.each do |mention|
			fid = mention.user.id
			Post.set_post(user, mention, fid, "Mentioned")		# Guarda --> tweets en los que ha sido mencionado el usuario
		end

		tweets.each do |tweet|
			if tweet.user_mentions
				mentions = tweet.user_mentions
				mentions.each do |mention|
					Post.set_post(user, tweet, mention.id.to_s, "Mention")	# Guarda --> menciones que ha hecho el usuario
				end
			end
	    end

	    activity_relationship(user)

	end

	def self.activity_relationship(user)
		user.friends.each do |friend|
	    	if (amount = user.posts.where(post_type: "Mention", friend: friend.fid).size) > 0
	    		Activity.set_activity(user, friend.fid, amount, "Mention")		# Guarda --> Registro de menciones que ha hecho el usuario (por usuario)
	    	end

	    	if (amount = user.posts.where(post_type: "Mentioned", friend: friend.fid).size) > 0	    		
	    		Activity.set_activity(user, friend.fid, amount, "Mentioned")	# Guarda --> Registro de menciones que en la que aparece el usuario (por usuario)
	    	end
	    	
	    	if (amount = user.posts.where(post_type: "Retweet", friend: friend.fid).size) > 0
	    		Activity.set_activity(user, friend.fid, amount, "Retweet")		# Guarda --> Registro de retweets que ha hecho el usuario (por usuario)
	    	end

	    	amount = user.posts.where(friend: friend.fid).size
			Relationship.set_relationship(amount, user, friend) if amount > 0	# Guarda --> Cantidad de actividades del usuario (por usuario)
	    end
	end

	def self.fb_friend(client, user, friend_id, post, type)
		new_friend = client.get_object(friend_id)
		Friend.set_friend(user, new_friend)

		friend = Friend.where(fid: friend_id)
		Post.set_post(user, post, friend[0].fid, type) if friend
	end

	SLICE_SIZE = 100
	
	def self.fetch_all_friends(user, client)
		client.friend_ids(user.screen_name).each_slice(SLICE_SIZE).with_index do |slice, i|
			client.users(slice).each_with_index do |f, j|
				Friend.set_friend(user, f)
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


	# Actualización de datos del usuario
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