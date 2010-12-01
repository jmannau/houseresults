#!/usr/bin/env ruby
require '../lib/house_results'
include HouseResults

# config/initializers/pdfkit.rb
PDFKit.configure do |config|
  config.wkhtmltopdf = '../bin/wkhtmltopdf'
end

suburbs = [ "brunswick", "coburg", "brunswick east", "northcote", "seddon", "prahran", "st kilda",
				"st kilda east", "richmond", "yarraville", "caulfield north", "caulfield", "elsternwick", "elwood", "kensington",
				"windsor", "preston", "south yarra",  "thornbury" ]
				
re = RealEstate.new
puts "fetching realestate.com.au info"
re.parse

d = Domain.new
puts "fetching homepriceguide.com.au info"
#d.parse

houses = re.houses + d.houses

interested = houses.find_all do |house|
	suburbs.include?(house.suburb.downcase) and
	house.type == "House" and
	house.status.downcase.include? "sold" and
	house.price < 800000 and
	house.bedrooms >= 2
end

interested.each do |i|
	puts "#{i.suburb} #{i.address} #{i.bedrooms} #{i.status} #{i.price.to_f}"
	if( i.id)
		puts "printing pdf #{i.to_s}"
		i.save_pdf
		#get the floor plan
		i.save_floorplan
	end
end