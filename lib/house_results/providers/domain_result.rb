module HouseResults
	class DomainResult < ResultBase
		
		def url
			"http://www.domain.com.au/public/Propertydetails.aspx?adid=#{self.id}" if self.id
		end
		
		def floorplan_url
			"http://www.domain.com.au/ore/Public/Gallery/FloorPlan.aspx?adid=#{self.id}"
		end
		
		private

	end
end