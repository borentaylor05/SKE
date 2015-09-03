class Array 
  def apify
    self.map(&:apify)
  end
end

class String
	def capitalize_each!
		replace self.split(" ").map{ |word| word.capitalize }.join(" ")
	end
end