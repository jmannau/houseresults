module HouseResults
	class RealEstateResult < ResultBase
		require 'nokogiri'
		require 'open-uri'
		
		def url
			"http://www.rs.realestate.com.au/#{self.id}" if self.id
		end
		
		def floorplan_url
			@floorplan_url ||= get_re_floorplan_url
		end
		
		private
		def get_re_floorplan_url
			if( self.id)
				doc = Nokogiri::HTML(open("http://www.realestate.com.au/floorplan.ds?id=#{self.id}"))
				node = doc.at_css("img[data-type=floorplan]")
				node[:src] if node
			end
		end
	end
end