class FxController < ApplicationController
	skip_before_action :verify_authenticity_token
	after_filter :cors_set_access_control_headers
	after_action :allow_iframe

	# Contains Fx Deadlines, Publications, Suburbs and redelivery
	
	# Begin Deadlines

	def get_deadlines_by_pub
		unless params[:pub].blank?
			if Deadline.contains(params[:pub]).count > 0
				days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
				deadlines = days.map do |day|
					hash = { day: day, deadlines: Deadline.day(day).contains(params[:pub]) }
				end
				respond({ status: 0, deadlines: deadlines })
			else
				respond({ status: 1, error: "No publication found with name: #{params[:pub]}." })	
			end
		else
			respond({ status: 1, error: "Must supply `pub` param." })
		end
	end

	def get_pubs
		pubs = []
		Deadline.uniq.pluck(:publication).each do |p|
			name = p.match('^[^\(]*').to_s.strip
			name = name.match('^[^\-]*').to_s.strip
			if name[0] == "*"
				name[0] = ''
			end
			if !pubs.include?(name)
				pubs.push(name)
			end
		end
		if pubs.count > 0
			respond({ status: 0, pubs: pubs })
		else
			respond({ status: 1, error: "No deadline publications in the database." })
		end
	end

	# End Deadlines

	def get_all_publications
		pubs = FxPublication.select(:name, :id)
		respond({ status: 0, pubs: pubs })
	end

	def get_publication
		if params.has_key?("publication_id")
			pub = FxPublication.find_by(id: params[:publication_id])
			if pub 
				if pub.mag
					respond({ status: 0, publication: pub, pricing: pub.fx_mag_pricing, ses: FxPublication.where(parent: pub.name) })
				else
					respond({ status: 0, publication: pub, pricing: pub.fx_mag_pricing })
				end
			else
				respond({ status: 1, error: "Publication #{params[:publication_id]} not found." })
			end
		else
			respond({ status: 1, error: "No publication specified." })
		end
	end

	def get_publication_pricing
		pub = FxPublication.find_by(id: params[:publication_id])
		if pub 
			if pub.se 
				respond({ status: 0, pricing: pub.fx_se_pricing })
			else
				respond({ status: 0, pricing: pub.fx_mag_pricing })
			end
		else
			respond({ status: 1, error: "Publication #{params[:publication_id]} not found." })
		end
	end

	def get_suburbs_for_publication
		pub = FxPublication.find_by(id: params[:publication_id])
		if pub 
			subs = pub.suburbs.select(:name, 'suburbs.id').to_a
			if subs.count > 0
				respond({ status: 0, suburbs: subs })
			else
				suburbs = []
				pubs = FxPublication.where(parent: pub.name)
				pubs.each do |p|
					p.suburbs.map do |burb| 
						burb.paper = p.name
						suburbs.push(burb.apify)
					end
				end
				respond({ status: 0, suburbs: suburbs, publication: pub })
			end
		else
			respond({ status: 1, error: "Publication not found." })
		end
	end

	def get_publications_for_suburb
		sub = Suburb.find_by(id: params[:suburb_id])
		if sub 
			if params.has_key?("strict") and params[:strict] == true
				pubs = sub.fx_publications.select(:name, :id)
				respond({ status: 0, publications: pubs })
			else
				all = []
				subs = Suburb.contains(sub.name)
				subs.each { |s| all.push(*s.fx_publications) }
				respond({ status: 0, publications: all })
			end
		else
			respond({ status: 1, error: "Suburb not found." })
		end
	end

	def cpts_for_publication
		pub = FxPublication.find_by(id: params[:publication_id])
		if pub 
			respond({ status: 0, cpts: pub.cost_per_thousands })
		else
			respond({ status: 1, error: "Publication not found" })
		end
	end

	def suburb_search 
		if params.has_key?("term") and !params[:term].blank?
			respond({ status: 0, matches: Suburb.contains(params[:term]) })
		else
			respond({ status: 1, error: "No :term param in request." })
		end
	end

	def get_redelivery
		r = Redelivery.find_by(id: params[:id])
		if r 
			respond({ status: 0, redelivery: r })
		else
			respond({ status: 1, error: "Redelivery #{params[:id]} not found" })
		end
	end

	def get_pub_redeliveries
		pub = FxPublication.find_by(id: params[:id])
		if pub 
			respond({ status: 0, redeliveries: pub.redeliveries })
		else
			respond({ status: 1, error: "Publication #{params[:id]} not found" })
		end
	end

	def red_publications
		pubs = []
		Redelivery.uniq.pluck(:fx_publication_id).each { |r|  pubs.push(FxPublication.find(r)) }
		pubs = pubs.sort_by { |pub| pub[:name] }
		respond({ status: 0, publications: pubs })
	end

	def redelivery_search
		reds = Redelivery.search(params[:term]).limit(30)
		respond({ status: 0, matches: reds.apify })
	end

	def get_code_rates
		if params.has_key?("pub")
			pub = FxPublication.find_by(id: params[:pub])
			if pub 
				respond({ status: 0, rates: FxCodeRate.where(fx_publication: pub) })
			else
				respond({ status: 1, error: "No pub with ID: #{params[:pub]}." })	
			end
		else
			respond({ status: 1, error: "Request needs 'pub' parameter." })
		end
	end

	def get_news_agent
		if params.has_key?("code")
			na = FxNewsAgent.find_by(code: params[:code])
			if na
				respond({ status: 0, na: na })
			else
				respond({ status: 1, error: "No News Agent with code: #{params[:code]}" })
			end
		else
			respond({ status: 1, error: "Request needs 'code' parameter." })
		end
	end

end
