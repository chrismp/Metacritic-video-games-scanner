def openURL(agent, url)
	p "OPENING #{url} at #{Time.now}"
	begin
		page=	agent.get(url)
	rescue Exception => e
		seconds=	60
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
