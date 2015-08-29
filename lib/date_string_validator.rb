class DateStringValidator < ActiveModel::EachValidator
	include ArcHelper
	def validate_each(object, attribute, value)		
		unless is_valid_date_string?(value)
		  	object.errors[attribute] << (options[:message] || "format is invalid -- #{value}") 
		end
	end
end