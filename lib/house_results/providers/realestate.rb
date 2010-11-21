module HouseResults
	class RealEstate < ProviderBase
		require 'nokogiri'
		require 'open-uri'
		require 'date'
		require 'bigdecimal'
		
		COL_ADDRESS = 0
		COL_BEDROOMS = 1
		COL_PRICE = 2
		COL_TYPE = 3
		COL_STATUS = 4
		COL_AUCTION_DATE = 5
		COL_AGENT = 6
		
		URL = 'http://www.rs.realestate.com.au/cgi-bin/rsearch?a=ars&s=vic'
		
		DATE_REGEX =  /(\d{1,2})\s(January|February|March|April|May|June|July|August|September|October|November|December)\s(\d{4})/i
		
		def parse(url=URL)
			
			doc = Nokogiri::HTML(open(url))

			self.date = Date.parse(doc.at_css(".introduction").content[DATE_REGEX])
			
			#find every results table
			doc.css(".ruiDataTable").each do |table|
				parse_suburb(table)
			end
			self
		end
		
		private
		def parse_suburb (suburb_node)
			_suburb = suburb_node.at_css("th").content.strip
			suburb_node.css('tbody tr').each do |tr|
				house = parse_property( tr)
				house.suburb = _suburb
				self.houses << house
			end
		end
		
		def parse_property( prop_node)
			#get all the table cels (<td></td>)
			td = prop_node.css('td')
			h = RealEstateResult.new
			#address sometime includes a link tag
			id = td[COL_ADDRESS].at_css('a')
			if id
				_id = id[:href].gsub(/\D/, "")
				_address= id.content
			else
				_id = nil
				_address = td[COL_ADDRESS].content
			end
			h.address = _address.strip
			h.id = _id
			h.bedrooms = td[COL_BEDROOMS].content.to_i
			h.price = BigDecimal.new(td[COL_PRICE].content.gsub(/\D/, ""))
			h.type = td[COL_TYPE].content.strip
			h.status = td[COL_STATUS].content.strip
			h.auction_date = td[COL_AUCTION_DATE].content.strip
			h.agent = td[COL_AGENT].content.strip
			return h
		end
	
	end
end