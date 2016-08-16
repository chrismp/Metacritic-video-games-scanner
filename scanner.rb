[
	"csv",
	"mechanize"
].each{|g|
	require g
}

require_relative "./methods.rb"

agent=					Mechanize.new
agent.user_agent_alias=	"Linux Firefox"

baseURL=	"http://www.metacritic.com"

sysLabel=		ARGV[0]
gamesCSV=		ARGV[1]
genresCSV=		ARGV[2]
publishersCSV=	ARGV[3]
criticsCSV=		ARGV[4]
csvInfoHash=	{
	gamesCSV => [
		"GameURL",
		"Title",
		"SystemLabel",
		"ReleaseDate",
		"Developer",
		"ESRB",
		"Description",
		"Metascore",
		"CriticScores",
		"UserScore",
		"UserScores"
	],
	genresCSV => [
		"Genre",
		"GameURL"
	],
	publishersCSV => [
		"PublisherURL",
		"Publisher",
		"GameURL"
	],
	criticsCSV => [
		"Critic",
		"GameURL",
		"Date",
		"Score"
	]
}

csvInfoHash.each{|fileName,headerArray|
	if File.exist?(fileName)!=true
		CSV.open(fileName,'w') do |csv|
			csv << headerArray
		end
	end
}

pgNum=	0
loop {
	gameListingURL=		baseURL+"/browse/games/release-date/available/"+sysLabel+"?page="+pgNum.to_s
	gameListingPage=	openURL(agent, gameListingURL)
	if gameListingPage==404
		p "#{gameListingURL} is 404 error, breaking"
		break
	end

	gameATags=	gameListingPage.css("#main .product .product_title a")
	if gameATags.length==0 or gameATags===nil
		p "NO MORE GAMES"
		break
	end

	gameATags.each{|gameATag|
		gameHref=	gameATag["href"]
		gameURL=	baseURL+gameHref
		gamePage=	openURL(agent,gameURL)
		if gamePage==404
			p "#{gameURL} is 404 error, skipping"
			next
		end

		title=			textStrip(gamePage.css("h1 span[itemprop='name']"))
		systemName=		textStrip(gamePage.css("span[itemprop='device']"))
		releaseDate=	textStrip(gamePage.css("span[itemprop='datePublished']"))
		developer=		textStrip(gamePage.css("li.developer span.data"))
		
		gamePage.css("li.publisher .data a").each{|a|
			publisherHref=	a["href"]
			publisher=		textStrip(a.css("span[itemprop='name']"))
			CSV.open(publishersCSV, 'a', headers:true) do |csv|
				row=				CSV::Row.new(csvInfoHash[publishersCSV],[])
				row["GameURL"]=		gameHref
				row["Publisher"]=	publisher
				row["PublisherURL"]=publisherHref
				csv << row
			end					
			# p [
			# 	gameHref,
			# 	publisherHref,
			# 	publisher
			# ]
		}
		
		description=	textStrip(gamePage.css("span[itemprop='description']")).gsub(/\r|\n/,' ')
		esrb=			textStrip(gamePage.css("span[itemprop='contentRating']"))
		metascore=		textStrip(gamePage.css(".metascore_summary span[itemprop='ratingValue']"))
		criticScores=	metascore==='' ? nil : textStrip(gamePage.css(".metascore_summary span[itemprop='reviewCount']"))
		userScore=		textStrip(gamePage.css(".userscore_wrap div.user")[0])
		userScore=		userScore == "tbd" ? nil : userScore
		userScores=		nil
		if userScore != nil
			userScores=	textStrip(gamePage.css(".userscore_wrap .count a")[0]).gsub(" Ratings",'')	
		end

		gamePage.css(".product_genre .data").each{|spanData|
			genre=	textStrip(spanData)
			CSV.open(genresCSV, 'a', headers:true) do |csv|
				row=			CSV::Row.new(csvInfoHash[genresCSV],[])
				row["GameURL"]=	gameHref
				row["Genre"]=	genre
				csv << row
			end
			# p [
			# 	gameHref,
			# 	genre
			# ]
		}

		CSV.open(gamesCSV, 'a', headers:true) do |csv|
			row=				CSV::Row.new(csvInfoHash[gamesCSV],[])
			row["GameURL"]=		gameHref
			row["Title"]=		title
			row["SystemLabel"]=	sysLabel
			row["ReleaseDate"]=	releaseDate
			row["Developer"]=	developer
			row["ESRB"]=		esrb
			row["Description"]=	description
			row["Metascore"]=	metascore
			row["CriticScores"]=criticScores
			row["UserScore"]=	userScore
			row["UserScores"]=	userScores
			csv << row
		end
		# p [
		# 	gameHref,
		# 	title,
		# 	systemName,
		# 	releaseDate,
		# 	developer,
		# 	description,
		# 	esrb,
		# 	metascore,
		# 	criticScores,
		# 	userScore,
		# 	userScores
		# ]

		criticsURL=	gameURL+"/critic-reviews"
		criticsPage=openURL(agent,criticsURL)
		if criticsPage==404
			p "#{criticsURL} is 404 errorm, skipping"
			next
		end

		criticsPage.css(".critic_review").each{|reviewTag|
			critic=		textStrip(reviewTag.css(".source")[0])
			reviewDate=	textStrip(reviewTag.css(".date")[0])
			criticScore=textStrip(reviewTag.css(".review_grade")[0])
			CSV.open(criticsCSV, 'a', headers:true) do |csv|
				row=			CSV::Row.new(csvInfoHash[criticsCSV],[])
				row["Critic"]=	critic
				row["GameURL"]=	gameHref
				row["Date"]=	reviewDate
				row["Score"]=	criticScore
				csv << row
			end
			# p [
			# 	critic,
			# 	gameHref,
			# 	reviewDate,
			# 	criticScore
			# ]
		}
	}

	pgNum+=1
}

p "FINISHED"