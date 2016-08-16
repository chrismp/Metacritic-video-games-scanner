def openURL(agent, url)
	p "OPENING #{url} at #{Time.now}"
	begin
		page=	agent.get(url)
	rescue Exception => e
		return 404 if e.to_s.include?("404")

		seconds=	30
		p "ERROR: #{e}"
		p "RETRYING IN #{seconds} seconds"
		p "--"
		sleep seconds
		retry
	end
	return page
end

def textStrip(elem)
	begin
	 	return elem.text.strip
	rescue Exception => e
		return nil
	end
end

def writeToSysNameLabelCSV(filename, sysLabelArray)
	CSV.open(filename,'a') do |csv|
		csv << sysLabelArray
	end
end
