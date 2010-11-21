module HouseResults

	class ResultBase
		require 'pdfkit'
		
		attr_accessor :address, :id, :bedrooms, :price, :type, :status, :auction_date, :agent, :suburb
		
		PDFKit.configure do |config|
		  config.default_options = {
		    :page_size => 'A4',
		    :print_media_type => true
		  }
		end
		
		def url
			raise NotImplementedError
		end
		
		def save_pdf( path = "./")
			pdf = PDFKit.new(self.url)
			pdf.to_file(path+self.to_s+".pdf")
		end
		
		def floorplan_url
			raise NotImplementedError
		end
		
		def save_floorplan( path = "./")
			_ext = File.extname(self.floorplan_url)
			`curl --silent '#{self.floorplan_url}' -o '#{path+self.to_s+_ext}'`
		end
		
		def to_s
			"#{self.suburb} #{self.address}"
		end
		
	end

end