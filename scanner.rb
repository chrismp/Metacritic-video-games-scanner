[
	"open-uri",
	"mechanize",
	"csv"
].each{|g|
	require g
}

def openURL(agent,url)
	p "OPENING #{url}"

	retryCount=	0
	begin
		page=	agent.get(url)
	rescue Exception => e
		if e.to_s.include?"429" or e.to_s.include?"503"
			sleep 30
			retry
		end

		if retryCount > 10
			return false
		end

		p "ERROR: #{e}"

		if e.to_s.include?"404"
			return false			
		end

		sleep 30
		retryCount+=1
		retry
	end
	return page
end

def textStrip(tag)
	return tag===nil ? nil : tag.text.strip
end


albumsCSV=	"Albums.csv"
artistsCSV=	"Artists.csv"
criticsCSV=	"CriticReviews.csv"
genresCSV=	"Genres.csv"
csvInfoHash= {
	albumsCSV => [
		"AlbumURL",
		"Album",
		"Artist",
		"ArtistURL",
		"Label",
		"LabelURL",
		"Summary",
		"ReleaseDate",
		"Metascore",
		"CriticScores",
		"UserScore",
		"UserScores"
	],
	criticsCSV => [
		"Critic",
		"AlbumURL",
		"Date",
		"Score"
	],
	genresCSV => [
		"Genre",
		"AlbumURL"
	]
}

csvInfoHash.each{|fileName,headersArray|
	if File.exist?(fileName)!=true
		CSV.open(fileName,'w') do |csv|
			csv << headersArray
		end
	end
}

agent=					Mechanize.new
agent.user_agent_alias=	"Linux Firefox"

baseURL=		"http://www.metacritic.com"
pgNum=			ARGV[0].to_i
loop{  
	albumDirectoryURL=	baseURL+"/browse/albums/release-date/available/date?page="+pgNum.to_s
	albumDirectoryPage=	openURL(agent,albumDirectoryURL)
	listProducts=		albumDirectoryPage.css(".list_products")	# `ol` containing `li` elements containing links to album pages
	if listProducts.length==0
		break
	end

	listProducts.css('a').each{|a|
		albumHref=	a["href"]

		albumExists=	false
		File.foreach(albumsCSV){|line|	
			if line.split(',')[0] === albumHref
				albumExists=	true
				break
			end
		}
		next if albumExists===true

		albumURL=	baseURL+albumHref
		next if openURL(agent,albumURL)===false

		albumPage=	openURL(agent,albumURL)
		album=		textStrip(albumPage.css(".product_title")[0])
		artist=		textStrip(albumPage.css(".product_artist a")[0])
		artistHref=	albumPage.css(".product_artist a")[0].attr("href")
		label=		textStrip(albumPage.css(".product_company .data")[0])
		labelHref=	albumPage.css(".publisher a")[0]===nil ? nil : albumPage.css(".publisher a")[0].attr("href")
		summary=	textStrip(albumPage.css(".product_summary .data span"))
		metascore=	textStrip(albumPage.css(".metascore_summary span[itemprop='ratingValue']")[0])
		releaseDate=textStrip(albumPage.css("span[itemprop='datePublished']")[0])
		criticScores=textStrip(albumPage.css(".metascore_summary span[itemprop='reviewCount']")[0])
		userScore=	textStrip(albumPage.css(".userscore_wrap div.user")[0])
		userScore=	userScore == "tbd" ? nil : userScore
		userScores=	nil
		if userScore != nil
			userScores=	textStrip(albumPage.css(".userscore_wrap .count a")[0]).gsub(" Ratings",'')	
		end

		CSV.open(albumsCSV,'a') do |csv|
			csv << [
				albumHref,
				album,
				artist,
				artistHref,
				label,
				labelHref,
				summary,
				releaseDate,
				metascore,
				criticScores,
				userScore,
				userScores
			]
		end

		albumPage.css(".product_genre .data").each{|genre|
			CSV.open(genresCSV,'a') do |csv|
				csv << [
					genre,
					albumHref
				]
			end
		}

		p album,artist,artistHref,label,labelHref,summary,metascore,criticScores,userScore,userScores,"=="

		criticsURL=	albumURL+"/critic-reviews"
		next if openURL(agent,criticsURL)===404
		criticsPage=openURL(agent,criticsURL)
		criticsPage.css(".critic_review").each{|reviewTag|
			critic=		textStrip(reviewTag.css(".source")[0])
			reviewDate=	textStrip(reviewTag.css(".date")[0])
			criticScore=textStrip(reviewTag.css(".review_grade")[0])
			CSV.open(criticsCSV,'a') do |csv|
				csv << [
					critic,
					albumHref,
					reviewDate,
					criticScore
				]
			end
			p critic,reviewDate,criticScore
			p "==="
		}
	}
	p "========"
	pgNum+=1
}
p "FINISHED"