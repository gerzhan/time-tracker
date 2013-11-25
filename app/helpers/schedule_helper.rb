module ScheduleHelper

	def javascript_data(data)
		str = ""
		first = true
		data.each do |k,v|
			if !first
				str += ","
			end
			first = false
			str += "['#{k}',#{v}]"
		end	
		str
	end

end
