class FxController < ApplicationController
	skip_before_action :verify_authenticity_token
	after_filter :cors_set_access_control_headers
	after_action :allow_iframe

	# Contains Fx Publications, Suburbs and Redelivery

	def get_all_publications
		pubs = FxPublication.select(:name, :id)
		respond({ status: 0, pubs: pubs })
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
					p.suburbs.each do |burb|
						b = burb.attributes
						b[:paper] = p.name
						suburbs.push(b)
					end
				end
				respond({ status: 0, suburbs: suburbs })
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
		all = []
		reds.each do |r|
			hash = r.attributes
			hash[:publication] = r.fx_publication.name
			all.push(hash)
		end
		respond({ status: 0, matches: all })
	end

end
