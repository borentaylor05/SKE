

task :create_fx_cats => :environment do
	cats = ["FAMILY NOTICES", "ADULT CLASSIFICATIONS", "AUTOMOTIVE", "EMPLOYMENT", "CHURCH NOTICES", "GENERAL", "NOTICES & SERVICES", "ENTERTAINMENT SERVICES", "RURAL, PETS, LIVESTOCK", "PROPERTY & ACCOMMODATION", "BILL ONLY CLASSIFIED", "CLASS FEATURE", "DIRECTORIES CLASSIFIED", "HOUSE FILLERS", "ONLINE EDITIONS", "LATE CLASSIFICATIONS", "LUGS", "TRADES AND SERVICES"]
	cats.each do |c|
		if !FxClassCat.exists?(name: c)
			FxClassCat.create!(name: c)
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