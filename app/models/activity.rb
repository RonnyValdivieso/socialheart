class Activity < ActiveRecord::Base
	
	belongs_to :user

	#Set activity for facebook users
	def self.set_fb_activity(user, post, friend)
		user.activities.find_by(aid: post['id'], friend: friend.fid) || create_fb_activity(user, post, friend)
	end
	
	def self.create_fb_activity(user, post, friend)
		user.activities.create(
			aid: post['id'],
			friend: friend.fid,
			date: post['created_time']
		)
	end

	#Set activity for twitter users
	def self.set_tw_activity(user, friend, amount, type)
		user.activities.find_by(friend: friend, activity_type: type) || create_tw_activity(user, friend, amount, type)
	end
	
	def self.create_tw_activity(user, friend, amount, type)
		user.activities.create(
			friend: friend,
			activity_type: type,
			level: amount
		)
	end

	def self.rate(higher, smaller)
		if higher > 0
			return ((smaller.to_f * 100)/higher).round
=begin
			if rate >= 0 && rate <= 15
				return "Muy bajo"
			elsif rate >= 16 && rate <= 40
				return "Bajo"
			elsif rate >= 41 && rate <= 65
				return "Normal"
			elsif rate >= 66 && rate <= 80
				return "Alto"
			elsif rate >= 81 && rate <= 100
				return "Muy alto"
			end
=end
		else
			return 0
		end
	end

end
