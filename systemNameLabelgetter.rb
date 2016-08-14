[
	"csv",
	"mechanize"
].each{|g|
	require g
}

require_relative "./methods.rb"

filename=	ARGV[0]
headerArray=[
	"Name",
	"Label"
]

CSV.open(filename,'w') do |csv|
	csv << headerArray
end

agent=					Mechanize.new
agent.user_agent_alias=	"Linux Firefox"

baseURL=	"http://www.metacritic.com"
initialURL=	baseURL+"/browse/games/title/"

begin
	page=					openURL(agent, initialURL)
rescue Exception => e
	p "ERROR: #{e}"
	sleep 60
	retry
end


page.css("#primary_nav_games_menu li.menu_item a").each{|menuItemA|
	gameSystemURL=	menuItemA["href"]
	gameSystem=		menuItemA.text

	if gameSystem=="Legacy"
		legacyPage=	openURL(agent, gameSystemURL)
		systemATags=legacyPage.css("#side .platforms_module .body a")
		systemATags.each{|a|
			sysName=	textStrip(a)
			sysLabel=	a["href"].split('/')[-2]
			writeToSysNameLabelCSV(filename, [sysName,sysLabel])
		}
	else
		gameSystemMainPage=	openURL(agent, gameSystemURL)
		browseGamesURL=		nil
		gameSystemMainPage.css(".nav_item_wrap a").each{|a|
			if a.text=="New Releases"
				browseGamesURL=	baseURL+a["href"]
				browseGamesURL=	browseGamesURL.gsub("new-releases","available")
				sysLabel=	browseGamesURL.split('/')[-2]
				writeToSysNameLabelCSV(filename, [gameSystem,sysLabel])
				break
			end
		}
	end
}

p "FINISHED"