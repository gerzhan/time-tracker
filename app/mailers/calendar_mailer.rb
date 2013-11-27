class CalendarMailer < ActionMailer::Base
  default from: "system@time-tracker.com",
  		  content_type: "text/Calendar"

  def send_schedule_request(user, time_request)
    body = File.open("#{Rails.root}/public/schedule_requests/#{time_request.id}.ics","r").read

    content_type "text/Calendar"

    mail(to: user.email,
         body: body,
         subject: "#{time_request.time_request_type ? time_request.time_request_type.name : ""} #{time_request.name}")
  end
end
