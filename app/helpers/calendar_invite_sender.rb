require 'pony'

module CalendarInviteSender

	def send_calendar_item(user, time_request)
		smtp_settings = {}

		if Rails.env.production?
			smtp_settings = {
			    :address        => 'smtp.mandrillapp.com',
			    :port           => '25',
			    :user_name      => 'user',
			    :password       => 'password',
			    :authentication => :plain, # :plain, :login, :cram_md5, no auth by default
			    :domain         => 'timetracker.io' # the HELO domain provided by the client to the server
			}
		elsif Rails.env.development? || Rails.env.test?
			smtp_settings = {
			    :address => "localhost",
			    :port => '1025'
			}
		end

		Pony.mail({
		  :to => user.email,
		  :body => File.open("#{Rails.root}/public/schedule_requests/#{time_request.id}.ics","r").read,
		  :content_type => "text/calendar",
		  :from => "system@timetracker.io",
		  :subject => "#{time_request.time_request_type ? time_request.time_request_type.name : ""} #{time_request.name}",
		  :via => :smtp,
		  :via_options => smtp_settings
		})
	end

end
