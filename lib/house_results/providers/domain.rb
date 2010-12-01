module HouseResults
	class Domain < ProviderBase
		require 'nokogiri'
		require 'date'
		require 'bigdecimal'
		require 'net/http'
		require 'tempfile'
		
		COL_SUBURB = 0
		COL_ADDRESS = 1
		COL_BEDROOMS = 2
		COL_TYPE = 2
		COL_PRICE = 3
		COL_STATUS = 4
		COL_AGENT = 5

		
		DATE_REGEX =  /(\d{1,2})(st|nd|rd|th)\s(January|February|March|April|May|June|July|August|September|October|November|December)\s(\d{4})/i
		
		URL = 'http://www.homepriceguide.com.au/saturday_auction_results/Melbourne.pdf'
		
		def parse(url = URL)
		
			f = download_file(url)
			
			#TODO fix up the path bizo.... need configuration or something similar..
			`pdftohtml -xml -c -i -noframes #{f}`
			
			doc = Nokogiri::XML(File.open("#{f}.xml"))
			
			#get each page
			doc.css("page").each do |page|
				#get only the text nodes on the page
				data = page.css("text")
				#sort the nodes from top to bottom so when can be sure of the order
				data_sorted = data.sort do |a, b|
					a[:top] == b[:top] ? a[:left].to_i <=> b[:left].to_i : a[:top].to_i <=> b[:top].to_i
				end
				
				#get the date
				unless self.date
					date_node = data_sorted.find{ |n|
						n.content =~ DATE_REGEX
					}
					self.date = Date.parse(date_node.content[DATE_REGEX])
				end
				
#				zip forward in the list until we get to the end of the header
				i = data_sorted.index{ |n| n.content.strip == 'Agent'}
				
				end_i = data_sorted.index{ |n| n.content =~ /KEY: S indicates property sold*/i}
				#until( data_sorted[i].content.strip == 'Agent')
				#	i+= 1
				#end
#				
#				move on to the next node which is the first property
				i += 1
#				parse each property until we get to the footer
				while i < end_i
					#find the end of this current house record
					j=i+1
					row = data_sorted[i][:top]
					#get all the items in the current row
					while( data_sorted[j][:top] == row) 
						j += 1
					end
					#if the next two nodes aren't at the as vertical position then 
					# the next node belongs with the current property
					if( data_sorted[j][:top] != data_sorted[j+1][:top])
						j += 1
					end
					#if we are at the last line on the page then ensure we aren't reading too many lines
					if( j >= end_i)
						j = end_i
					end

					#make the real estate agent field optional
					r = parse_info(data_sorted[i..j-1])
					i = j

					self.houses << r
					
				end
			end
			#don't forget to clean up the temp files
			File.delete(f) if File.exists?(f)
			File.delete("#{f}.xml") if File.exists?("#{f}.xml")
			return self
		end
		
		
		def parse_info(nodes)
			
			r = DomainResult.new
			r.suburb = nodes[COL_SUBURB].content.strip
			r.id = parse_id(nodes[COL_ADDRESS])
			r.address = nodes[COL_ADDRESS].content.strip
			r.bedrooms = parse_bedrooms(nodes[COL_BEDROOMS]).to_i
			r.type = parse_type(nodes[COL_TYPE])
			r.price = parse_price(nodes[COL_PRICE])
			r.status = parse_status(nodes[COL_STATUS])
			r.agent = nodes[COL_AGENT].content.strip if nodes[COL_AGENT]
			#check if there is two agent info lines
			r.agent += nodes[COL_AGENT+1].content.strip if nodes[COL_AGENT+1]
			return r
			
		end
		
		private
		
		#returns a temporary file path
		def download_file(url)
			f = Tempfile.new(File.basename(url))
			path = f.path
			url = URI.parse(url)
			Net::HTTP.start( url.host) { |http|
				resp = http.get(url.path)
				f.write(resp.body)
			}
			f.close
			return path
		end
		
		def parse_id(address_node)
			link = address_node.at_css("A")
			if( link)
				id = link[:href].match(/adid=(\d*)/i)
				id = id[1] if id
			end
			return id
		end
		
		def parse_price(price_node)
			BigDecimal.new(price_node.content.gsub(/\D/, ""))
		end
		
		def parse_status(status_node)
			_val = status_node.content.strip
			case _val
				when 'S' 
					return 'Sold'
				when 'SP' 
					return 'Sold Prior'
				when 'PI' 
					return 'Passed In'
				when 'PN' 
					return 'Sold Prior not Disclosed'
				when 'SN' 
					return 'Sold not Disclosed'
				when 'NB' 
					return 'No Bid'
				when 'VB' 
					return 'Vendor Bid'
				when 'o res' 
					return 'Other Residential'
				when 'w' 
					return 'Withdrawn'
				when 'N/A' 
					return 'Price or Highest Bid not Available'
				when 'SA' 
					return 'Sold after Auction'
				when 'SS' 
					return 'Sold after Auction Price not Disclosed'
				else 
					return _val
			end
		end
		
		def parse_bedrooms( bedroom_node)
			bedroom_node.content.strip[/\d*/i] || 0
		end
		
		def parse_type( type_node)
			_type = type_node.content.strip[/h|u|t|dev site|o res|land/i]
			case _type
				when 'h'
					return "House"
				when 'u'
					return 'Unit'
				when 't'
					return 'Townhouse'
				when 'dev site'
					return 'Development Site'
				when 'o res'
					return 'Other Residential'
				when 'land'
					return 'Land'
				else
					return _type
				end
		end
	end
end