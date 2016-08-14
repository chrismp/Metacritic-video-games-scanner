def openURL(agent, url)
	p "OPENING #{url}"
	begin
		page=	agent.get(url)
	rescue Exception => e
		p "ERROR: #{e}"
		sleep 60
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