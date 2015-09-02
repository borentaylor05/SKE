class Array 
  def apify
    self.map { |s| s.apify }
  end
end