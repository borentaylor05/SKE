class FxController < ApplicationController
	skip_before_action :verify_authenticity_token
	after_filter :cors_set_access_control_headers
	after_action :allow_iframe

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

end
