require 'pony'

module CalendarInviteSender

	def send_calendar_item(user, time_request)
		smtp_settings = {}

		if Rails.env.production?
			config.action_mailer.smtp_settings = {
			    :address   => "smtp.sendgrid.net",
			    :port      => 25, # ports 587 and 2525 are also supported with STARTTLS
			    :enable_starttls_auto => true, # detects and uses STARTTLS
			    :user_name => "#{ENV["SENDGRID_USERNAME"]}",
			    :password  => "#{ENV["SENDGRID_PASSWORD"]}", 
			    :authentication => 'login', # Mandrill supports 'plain' or 'login'
			    :domain => 'work-tracker.herokuapp.com', # your domain to identify your server when connecting
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
		  :content_type => "text/calendar;
 charset=UTF-8;
 method=REQUEST;
 name='meeting.ics'",
		  :headers => { "Mime-Version" => "1.0", "Content-Transfer-Encoding" => "7bit" },
		  :from => "system@timetracker.io",
		  :subject => "#{time_request.time_request_type ? time_request.time_request_type.name : ""} #{time_request.name}",
		  :via => :smtp,
		  :via_options => smtp_settings
		})
	end

end
