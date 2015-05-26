require 'csv'
require 'Util'
require 'Jive'
require 'Jive2'
require 'Auth'

task clean_missions: :environment do
	UserMission.destroy_all
	Mission.destroy_all
	EmpowerMission.destroy_all
	JiveMission.destroy_all
end

task clean_messages: :environment do 
	Message.destroy_all
	MessageTracker.destroy_all
	User.all.each { |u| u.update_attributes(pending_urgent: false) }
end

task :create_fx_cats => :environment do
	cats = ["FAMILY NOTICES", "ADULT CLASSIFICATIONS", "AUTOMOTIVE", "EMPLOYMENT", "CHURCH NOTICES", "GENERAL", "NOTICES & SERVICES", "ENTERTAINMENT SERVICES", "RURAL, PETS, LIVESTOCK", "PROPERTY & ACCOMMODATION", "BILL ONLY CLASSIFIED", "CLASS FEATURE", "DIRECTORIES CLASSIFIED", "HOUSE FILLERS", "ONLINE EDITIONS", "LATE CLASSIFICATIONS", "LUGS", "TRADES AND SERVICES"]
	cats.each do |c|
		if !FxClassCat.exists?(name: c)
			FxClassCat.create!(name: c)
		end
	end
end

task api_test: :environment do 
	users = [
		{
			current: 'previousname',
			new_username: 'LOOK_IM_UPDATED'
		},
		{
			current: 'TestKeimig',
			new_username: 'put_test_2'
		}
	]
	users.each do |u| 
		puts u
		resp = Jive.grab("#{Jive.uat}/people/username/#{u[:current]}", Auth.uat) # GET request
		id = resp["id"]
		resp = Util.fix_user(resp) # makes sure family and give name are in the updated user object
		resp["jive"]["username"] = u[:new_username]
		puts "JSON for #{u[:current]} --> #{resp.to_json}"
		puts "Response for updating #{u[:current]} --> "
		resp = Jive.update("#{Jive.uat}/people/#{id}", resp, Auth.uat) # PUT request with updated user object as param
		if resp.code > 399
			puts "ERROR: #{resp["error"]}"
		else
			puts resp 
		end
	end
end

task :move_category => :environment	do
	FxClassification.all.each do |c|
		cat = FxClassCat.find_by(name: c.category)
		c.fx_class_cat = cat
		c.save
	end
end

task :clean_maintainers => :environment	do
	Maintainer.destroy_all
	OldComment.destroy_all
	OldContent.destroy_all
	ArticleRequest.destroy_all
end

task create_suburbs: :environment do 
	subs = %w{Carrington Freemans\ Bay Grey\ Lynn Herne\ Bay Kingsland Newton Ponsonby Pt\ Chevalier St\ Marys\ Bay Waterview Western\ Springs\ and\ Westmer. Balmoral Epsom Greenlane Hillsborough Lynfield Mt\ Albert Mt\ Eden Mt\ Roskill Morningside New\ Windsor One\ Tree\ Hill Onehunga Oranga Owairaka Penrose\ (not\ Te\ Papapa) Royal\ Oak Sandringham Three\ Kings Waikowhai Wesley. Ellerslie Glen\ Innes Glendowie Kohimarama Meadowbank Mission\ Bay Mt\ Wellington\ (including\ Panama\ Road) Orakei Newmarket Panmure Parnell Grafton Pt\ England Remuera St\ Johns St\ Heliers Tamaki. Beachlands Botany\ Downs Bucklands\ Beach Burswood Cascades Chapel\ Downs Chapel\ Heights Cockle\ Bay Cumbria\ Downs Dannemora Donegal\ Park East\ Tamaki East\ Tamaki\ Heights Eastern\ Beach Edgewater Farm\ Cove Golflands Half\ Moon\ Bay Highland\ Park Howick Huntington\ Park Maraetai Mellons\ Bay Northpark Ormiston Pakuranga Pakuranga\ Heights Point\ View\ Park Sacramento Shamrock\ Park Shelly\ Park Somerville Sunnyhills Whitford.\ Includes\ Rural\ Delivery\ areas: \ Howick\ RD.  Clendon Clover\ Park Favona Flat\ Bush Goodwood\ Heights Hill\ Park Homai Ihumatao Mahia\ Park Mangere\ Bridge Mangere\ Central Mangere\ East Manukau\ Central Manukau\ Heights Manurewa Manurewa\ East Middlemore Otahuhu Otara Papatoetoe Peninsula\ Park Puhinui Randwick\ Park The\ Gardens Totara\ Heights Wattle\ Downs Weymouth Wiri.  Arkels\ Bay Army\ Bay Dairy\ Flat Coatesville Gulf\ Harbour Hatfields\ Beach Hobbs\ Bay Little\ Manly Manly Matakatia\ Bay Maygrove Okoramai\ Bay Orewa Pine\ Valley Red\ Beach Redvale Silverdale Stanmore\ Bay Stillwater The\ Grange Tindalls\ Beach Whangaparaoa.\ Includes\ Rural\ Delivery\ areas:\ Silverdale\ RD Albany\ RD3\(east)4.  Albany Beach\ Haven Bayswater Bayview Belmont Birkdale Birkenhead Brookfield Browns\ Bay Bushlands Campbells\ Bay Castor\ Bay Chatswood Chester\ Park Devonport Forrest\ Hill Glenfield Greenhithe Hillcrest Mairangi\ Bay Meadowood Milford Murrays\ Bay Northcote Northcross Okura Paremoremo Pinehill Rothesay\ Bay Schnapper\ Rock Stanley Point Sunnynook Takapuna Torbay Unsworth\ Heights Waiake Wainoni Westlake Windsor\ Park. Bethells\ Beach West\ Coatesville Helensville Huapai Kaukapakapa Kumeu Muriwai Parakai Riverhead Taupaki Waimauku Waitakere Waitoki Whenuapai semi-rural\ areas\ of\ Massey Ranui Swanson.\ Includes\ Rural\ Delivery\ areas:\ Henderson\ RD1 2.\ Helensville\ RD1 2.\ Kumeu\ RD1 2.\ Kaukapakapa\ RD1 3.\ Waimauku\ RD1|2 3.\ Warkworth\ RD4\ (south).\ Albany\ RD3\ (west). Ararimu Alfriston Ardmore Brookby Clarks\ Beach Clevedon Conifer\ Grove Drury Hunua Karaka Kawakawa\ Bay Kingseat Opaheke Orere\ Point Pahurehure Papakura Paparimu Patumahoe Ponga Pukekohe\ retail\ area Ramarama Red\ Hill Runciman Seagrove Takanini Te\ Hihi Waiau\ Pa.\ Includes\ Rural\ Deliver\ Areas:\ Drury\ RD\ 1||3.\ Papakura\ RD\ |3|4|5\ and\ Manurewa\ RD1. Northern\ boundary\ at\ Wellsford\ up\ to\ Mangawhai\ Heads\ down\ to\ the\ southern\ Albany\ Heights\ boundary including\ Kumeu Helensville Hibiscus\ Coast Warkworth Wellsford\ and\ the\ Kowhai\ Coast.\ Extended\ circulation\ every\ second\ Tuesday\ reaches\ further\ North\ and\ in\ to\ the\ Kaipara covering\ Kaiwaka Mangawhai Maungaturoto\ and\ Paparoa. Ostend Blackpool Oneroa Omiha Onetangi Palm\ Beach Surfdale\ -\ including\ rural\ delivery\ and\ Orapiu\ as\ well\ as\ shops\ and\ businesses Fullers\ Ferries SeaLink\ Ferries\ and\ Matiatia\ wharf.\ Also\ available\ at\ Devonport\ Wharf Freemans\ Bay\ New\ World\ and\ Foodtown\ Quay\ Street. Avondale Blockhouse\ Bay Glen\ Eden Glendene Green\ Bay Harbour\ View Henderson Henderson\ Valley Herald\ Island Hobsonville Kelston Laingholm Massey Massey\ East Massey\ North New\ Lynn Palm\ Heights Ranui Sunnyvale Swanson Te\ Atatu\ Peninsula Te\ Atatu\ South Titirangi Waima Waimanu\ Bay Waitakere Western\ Heights Westgate West\ Harbour Whenuapai Woodlands\ Park. Doubtless\ Bay RD3\ Kaitaia Kaeo Kerikeri Waipapa Paihia Opua Russell\ and\ surrounding\ rural\ areas.\ Incorporating\ features\ from\ the\ Northern\ News. Kaipara\ district\ including\ Dargaville Te\ Kopuru Ruawai Paparoa Maungaturoto\ to\ Mangawhai\ and\ all\ rural\ areas.\ To\ the\ north\ as\ far\ as\ Waipoua south\ to\ Pouto\ and\ to\ Tangiteroria\ and\ Mangawhai\ in\ the\ east. Kaikohe Kawakawa Moerewa Ohaeawai Okaihau North\ &\ South\ Hokianga Kaitaia\ and\ rural\ properties\ in\ surrounding\ areas.\ Northern\ News\ is\ also\ incorporated\ in\ the\ Bay\ Chronicle\ on\ Thursdays\ and\ distributed\ to\ Doubtless\ Bay Mangonui Waipapa Paihia Opua Russell\ and\ Kerikeri. Whau\ Valley Tikipunga Woodhill Parahaki Kamo Kensington Raumanga Onerahi Otangarei Otaika Morningside Maunu Regent Horahora Hikurangi Ruakaka\ and\ Waipu.\ Rural\ Areas\ include:\ Whangarei\ RD1|RD|RD3|RD4|RD5|RD6|RD8|RD9. Porirua Titahi\ Bay Tawa Linden Kenepuru Ascot\ Park Waitangirua Whitby Paremata Pukerua\ Bay Plimmerton Pauatahanui Cannons\ Creek Elsdon Onepoto\ and\ Grenada\ North. Pukerua\ Bay Paekakariki Paraparaumu Waikanae Otaki Te\ Horo\ and\ Raumati. Foxton Shannon\ and\ Levin Lower\ Hutt Petone Eastbourne Wainuiomata Stokes\ Valley Naenae Taita Normandale Maungaraki Kelson Miramar Seatoun Strathmore\ and\ Bays Kilbirnie Haitaitai Lyall\ Bay Island\ Bay Owhiro\ bay Vogeltown Mornington Newtown Berhampore Central\ City\ Area\ including\ -\ Mt\ Victoria Roseneath Te\ Aro Mt\ Cook Aro\ Valley\ and\ Kelburn The\ Northern\ suburbs\ of\ Karori Northland Wadestown Highland\ Park Ngaio Khaiwharawhara Khandallah Ngauranga Newlands Johnsonville Paparangi Churton\ Park Tawa\ &\ Linden.\ Upper\ Hutt Te\ Marua Totara\ Park Akatarawa Haywards\ Hill Manor\ Park Trentham Silverstream\ and\ Stokes\ Valley. Pahiatua\ to\ Cape\ Palliser Pahiatua Eketahuna Masterton Carterton Greytown Featherston\ and\ Martinborough. Wanganui Rangitikei Manawatu Horowhenua Kapiti Wairarapa Southern\ Hawkes\ Bay\ and\ Southern\ Taranaki. Ohakune Waiouru\ (including\ Military\ Camp\ housing\ areas) Taihape Mangaweka Ohingaiti Hunterville\ and\ the\ rural\ areas\ in\ between. Manawatu\ and\ Rangitikei\ Districts\ which\ includes\ the\ bustling\ rural\ townships\ of\ Feilding Marton Bulls Hunterville Taihape\ and\ their\ surrounding\ communities. Palmerston\ North\ and\ Ashhurst Marton Bulls Sanson Woodville Pahiatua Foxton\ (including\ Foxton\ Beach)\ and\ Shannon. Mokau Urenui Waitara New\ Plymouth Oakura Inglewood Tariki Okato Rahotu Stratford Kaponga Eltham Opunake Manaia Normanby Hawera Patea Waverley Taumarunui Owhango Ohakune Raetihi Whakapapa\ and\ Turoa\ Skifields National\ Park\ and\ to\ selected\ outlets\ in\ Turangi\ and\ Waiouru Huntly Te\ Kauwhata Meremere Glen\ Murray Rangiriri Ohinewai Te\ Hoe Rotowaro Glen\ Afton Naike Waiterimu Te\ Akau Taupiri Waingaro Ngaruawahia\ township\ and\ Orini Drury North\ Waikato Pukekohe Waiuku Tuakau Patumahoe Pokeno Hunua Karaka Clarks\ Beach Waiau\ Pa Awhitu Buckland Bombay Kaiaua Miranda Maramarua Mercer Meremere Pukekawa Onewhero Port\ Waikato Puni Aka\ Aka Otaua Paerata Runciman Mangatawhiri Mangatangi Te\ Hihi Kingseat Ramarama Pukeoware Mauku Glenbrook Glenbrook\ Beach Waipipi Kohekohe Te\ Toro Pollok Matakawau Big\ Bay Orua\ Bay Wattle\ Bay Te\ Kohanga\ and\ Waikaretu. Aberdeen Ashmore Beerescourt Callum\ Brae Chartwell Chedworth\ Park Claudelands Crawshaw Deanwell Dinsdale Enderley Fairfield Fairview\ Downs Fitzroy Flagstaff Forest\ Lake Frankton Glaisdale Glenview Grandview\ Heights Hamilton\ Central Hamilton\ North Hamilton\ East Hamilton\ West Harrowfield Hillcrest Huntington Livingstone Magellan\ Rise Maeroa Melville Pukete Queenwood Ruakura Riverlea Rotokauri Rototuna Silverdale Stonebridge St\ Andrews St\ James\ Park St\ Petersburg Somerset\ Heights Stonebridge Te\ Rapa Te\ Kowhai Temple\ View Thornton Western\ Heights Whitiora Woodsy's\ House Cambridge\ East Leamington Tamahere Matangi Te\ Miro Hautapu Bruntwood Fencourt Pukeroro Kaipaki Pukemiru Monavale Rotoorangi Kairangi Hora\ Hora Maungatautari Pukekura Karapiro Whitehall and\ French\ Pass. Hinuera Peria Turanga-o-moana Te\ Poi Waharoa Walton Wardville Thames Thames\ Coast Coromandel\ Town Matarangi Whitianga Cooks\ Beach Hahei Tairua Pauanui Whiritoa Whangamata Waihi Waihi\ Beach Athenree Paeroa Ngatea Hauraki\ Plains Patetonga Kaihere Kaiaua and\ Miranda Fenton\ Park Glenholme Ohinemutu Owhata Mangakakahi Western\ Heights Westbrook Fordlands Springfield Tihi-Ōtonga Lynmore Victoria Pukehangi Kawaha\ Point Ngongotaha Hamurana Tikitere Tarawera Okareka Koutu Hillcrest Utuhina Whakarewarewa Ngapuna Holdens\ Bay Hannahs\ Bay Morrinsville\ and\ Te\ Aroha\ and\ their\ rural\ communities\ in\ rolling\ Waikato\ farmland Tokoroa Putaruru Tirau Mangakino Arapuni Whakamaru\ and\ Atiamuri\ and\ the\ surrounding\ rural\ environs.  Wharewaka Nukuhau Richmond\ Heights Mount\ View Acacia\ Bay Rainbow\ Point Tauhara Hilltop Gradwell Taupo\ CBD Five\ Mile\ Bay Wairakei Waitahanui Queenstown Central\ Otago Clutha\ District Gore Mossburn Lumsden Tapanui Eastern\ Southland. Winton Bluff Riverton Te\ Anau Otago Southland Collingwood Takaka Motueka Mapua Richmond Tapawera Wakefield Brightwater Murchison Nelson\ Lakes Stoke Atawhai Rai\ Valley Okiwi\ Bay D'Urville\ Island Amberley Cheviot Culverden Greta\ Valley Hanmer\ Springs Hawarden Leithfield Parnassus Waiau Waikari Waipara Cust Loburn Ohoka Oxford Rangiora Sefton Woodend Arthur's\ Pass Burnham Darfield Dunsandel Glentunnel Halswell Hororata Kirwee Lake\ Coleridge Leeston Lincoln Little\ River Motukarara Prebbleton Rolleston Sheffield Southbridge Springfield Springston Tai\ Tapu (Tai\ Tap) West\ Melton Yaldhurst Addington Aranui Avonhead Avonside Avonside Banks\ Penninsula Beckenham Belfast Bryndwr Burnside Burwood Cashmere Cracroft Edgeware Fendalton Ferrymead Halswell Heathcote Hoon\ Hay Hornby Linwood Lyttelton Mairehau Merivale New\ Brighton Oaklands Opawa Papanui Paparoa Redcliffs Riccarton Shirley Somerfield South\ New\ Brighton South\ Shore Spreydon St\ Martins Sumner Sydenham Woolston Arundel Ashburton Freezing\ Point Hinds Lake\ Heron Mayfield Methven Mt\ Hutt Mt\ Somers Rakaia Kaikoura Ward Seddon Blenheim Picton Havelock Rai\ Valley Blenheim Picton Kaikoura Rai\ Valley\ and\ Havelock Whole\ of\ the\ Kaikoura\ township\ and\ rural\ areas.\ North\ to\ Clarence\ Bridge South\ to\ Oaro\ and\ inland\ to\ Mt\ Lyford Arundel Ashburton Freezing\ Point Hinds Lake\ Heron Mayfield Methven Mt\ Hutt Mt\ Somers Rakaia Burke\ Pass Cave Fairlie Geraldine Glenavy Kimbell Kurow Lake\ Benmore Lake\ Pukaki Lake\ Tekapo Makikihi Mt.\ Cook Omarama Orari Otematata Peel\ Forest Pleasant\ Point St.\ Andrews Temuka Timaru Twizel Waimate Winchester Burke\ Pass Cave Fairlie Geraldine Glenavy Kimbell Kurow Lake\ Benmore Lake\ Pukaki Lake\ Tekapo Makikihi Mt.\ Cook Omarama Orari Otematata Peel\ Forest Pleasant\ Point St.\ Andrews Temuka Timaru Twizel Waimate Winchester Duntroon Dansys\ Pass Western Oamaru Hampden Moeraki\ Boulders Palmerston Ranfurly Otematata Duntroon Dansys\ Pass Western Oamaru Hampden Moeraki\ Boulders Palmerston Ranfurly Otematata}
	subs.each do |s|
		s = s.encode('UTF-8', :invalid => :replace, :undef => :replace)
		if !Suburb.find_by(name: s.strip)
			Suburb.create!(name: s.strip)
		end
	end 
end

task check_pubs: :environment do 
	pubs = %w{Auckland\ City\ Harbour\ News Central\ Leader East\ &\ Bays\ Courier Eastern\ Courier Manukau\ Courier North\ Harbour\ News North\ Shore\ Times Nor-West\ News Papakura\ Courier Rodney\ Times Waiheke\ Marketplace Western\ Leader The\ Bay\ Chronicle Dargaville\ District\ News Northern\ News Whangarei\ Leader Kapi\ Mana\ News Kapiti\ Observer Horowhenua\ Mail The\ Hutt\ News The\ Wellingtonian Upper\ Hutt\ Leader Wairarapa\ News Central\ District\ Farmer Central\ District\ Times Feilding\ Herald\ /\ Rangitikei\ Mail The\ Tribune North\ Taranaki\ Midweek South\ Taranaki\ Star Ruapehu\ Press North\ Waikato\ News Franklin\ County\ News Hamilton\ Press Cambridge\ Edition Matamata\ Chronicle Hauraki\ Herald Rotorua\ Review Piako\ Post South\ Waikato\ News Taupo\ Times Queenstown\ Mirror Clutha\ Leader Newslink Invercargill\ Eye Otago\ Southland\ Farmer Tasman/Richmond\ Leader Nelson\ Leader Northern\ Outlook Central\ Canterbury\ News Christchurch\ Mail Mid\ Canterbury\ Herald Marlborough\ Midweek Saturday\ Express Kaikoura\ Star Mid\ Canterbury\ Herald South\ Canterbury\ Herald Central\ South\ Island\ Farmer\ -\ South Waitaki\ Herald}
	pubs.each do |p|
		if Deadline.contains(p).blank?
			puts p
		end
	end
end

task create_relationships: :environment do 
	current_pub = nil
	CSV.foreach('suburbs_all.csv', :headers => true) do |row|
		current_pub = FxPublication.find_by(name: row[1].strip)
		if current_pub
			row[0].split(",").each do |s|
				s = s.encode('UTF-8', :invalid => :replace, :undef => :replace)
				sub = Suburb.find_by(name: s.strip)
				if !sub
					puts s
				else
					current_pub.suburbs << sub
				end
			end
		else
			puts "Error at #{row[1]}"
		end
	end
end

task fix_missing: :environment do 
	subs = ["Tawa & Linden", "Upper Hutt", "Tihi-Otonga", "Whakamaru and Atiamuri and the surrounding rural environs", "Whitford", "Includes Rural Delivery areas: Howick RD", "Albany RD 2|3(east)|4", "Swanson", "Includes Rural Delivery areas: Henderson RD1|2 Helensville RD1|2 Kumeu RD1|2 Kaukapakapa RD1|3 Waimauku RD1|2|3. Warkworth RD4 (south). Albany RD3 (west)", "Waiau Pa","Includes Rural Deliver Areas: Drury RD 1|2|3. Papakura RD 2|3|4|5 and Manurewa RD1","Northern boundary at Wellsford up to Mangawhai Heads", "down to the southern Albany Heights boundary", "Surfdale - including rural delivery and Orapiu as well as shops and businesses", "Ruakaka", "Waipu", "Rural Areas include: Whangarei RD1|RD2|RD3|RD4|RD5|RD6|RD8|RD9"]
	pubs = ["The Wellingtonian", "Upper Hutt Leader", "Rotorua Review", "South Waikato News", "Eastern Courier", "Eastern Courier", "North Harbour News", "Nor-West News", "Nor-West News", "Papakura Courier", "Papakura Courier", "Rodney Times", "Rodney Times", "Waiheke Marketplace", "Whangarei Leader", "Whangarei Leader", "Whangarei Leader"]
	c = 0 
	subs.each do |sub| 
		pub = pubs[c]
		s = Suburb.find_by(name: sub.strip)
		if !s 
			s = Suburb.create!(name: sub.strip)
		end
		p = FxPublication.find_by(name: pub.strip)
		if !p 
			puts "Error: #{pub}"
		else
			p.suburbs << s
			puts "#{s.name} <----- #{p.name}"
		end
		c = c + 1
	end
end

task cost_per_thousand_init: :environment do 
	CSV.foreach("cost_per_thousand.csv") do |row|
		publications = row[0]
		if row[1].strip == "n/a"
			cur_cost = 0
		else
			cur_cost = row[1].gsub!(",", "").to_i
		end
		if !CostPerThousand.create(publications: publications, cost: cur_cost)
			puts "ERROR -- #{row[0]}"
		end
	end
end

task cost_per_thousand_associations: :environment do 
	CSV.foreach("cost_per_thousand.csv") do |row|
		cpt = CostPerThousand.find_by(publications: row[0])
		row[0].split("+").each do |pub|
			pub = pub.strip
			p = FxPublication.find_by(name: pub)
			if !p
				puts pub
			else
				cpt.fx_publications << p
			end
		end
	end
end

task simple_test: :environment do 
	cdc = CDC.new('dev')
	cdc.import_a_to_z("a_to_c.csv")
end

task get_jive_ids: :environment do 
	jive = Jive2.new('social')
	User.where(jive_id: 0).each do |u|
		resp = jive.grab("/people/username/#{u.employee_id}")
		if resp["id"]
			puts resp["id"]
			u.update_attributes(jive_id: resp["id"])
		else
			puts resp
		end
	end
end
