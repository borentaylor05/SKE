class FxClassificationController < ApplicationController
	skip_before_action :verify_authenticity_token
	after_filter :cors_set_access_control_headers
	after_action :allow_iframe
	before_action :verify

	def get_classifications
		if params.has_key?("cat")
			cur = FxClassCat.find(params[:cat])
			respond({ status: 0, c: [{ cat: cur.name, all: FxClassification.where(fx_class_cat: cur) }] })
		elsif params.has_key?("search")
			respond({ status: 0, c: get_matches(params[:search]) })	
		else
			respond({ status: 1, error: "This request requires a parameter" })
		end
	end

	def get_categories
		respond({ status: 0, cats: FxClassCat.select(:name, :id) })
	end

	private

		def get_matches(term)
			cats = []
			FxClassification.contains(term).each do |c|
				cur = c.fx_class_cat
				if !cats.index{ |item| item[:cat] == cur.name}
					cats.push({ cat: cur.name, all: [c] })
				else
					i = cats.index{ |item| item[:cat] == cur.name}
					cats[i][:all].push(c)
				end
			end
			return cats
		end

end
