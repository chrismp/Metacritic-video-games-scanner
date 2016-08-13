require "mechanize"

agent=					Mechanize.new
agent.user_agent_alias=	"Linux Firefox"


url=	"http://www.metacritic.com/browse/games/title/"
begin
	page=					agent.get(url)
rescue Exception => e
	p "ERROR: #{e}"
	sleep 60
	retry
end

page.css("#primary_nav_games_menu li.menu_item a").each{|menuItemA|
	gameSystemURL=	menuItemA["href"]
	gameSystem=		menuItemA.text

	if gameSystem=="Legacy"
		
	else
		gameSystemMainPage=	agent.get(gameSystemURL)
		browseAZURL=		nil
		gameSystemMainPage.css(".nav_item_wrap a").each{|a|
			if a.text=="Browse A-Z"
				browseAZURL=	a["href"]
				break
			end
		}

		p browseAZURL
	end
}
