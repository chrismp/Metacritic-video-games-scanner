[
	"open-uri",
	"mechanize"
].each{|g|
	require g
}

agent=					Mechanize.new
agent.user_agent_alias=	"Linux Firefox"

url=					"http://www.metacritic.com/browse/albums/release-date/available"
begin
	page=					agent.get(url)
rescue Exception => e
	p "ERROR: #{e}"
	sleep 60
	retry
end

lastPageNumberTag=		page.css(".page_num")[-1]
lastPageString=			lastPageNumberTag.text.strip
lastPageNumber=			lastPageString.to_i

puts lastPageNumber