module HouseResults
	class DomainResult < ResultBase
		
		def url
			"http://www.domain.com.au/Public/PropertyBrochure.aspx?adid=#{self.id}" if self.id
		end
		
		def floorplan_url
			"http://www.domain.com.au/ore/Public/Gallery/FloorPlan.aspx?adid=#{self.id}"
		end
		
		def save_floorplan( path = "./")
			pdf = PDFKit.new(self.floorplan_url)
			pdf.to_file(path+clean_filename(self.to_s+" floorplan.pdf"))
		end
		
		private

	end
end