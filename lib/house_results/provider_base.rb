module HouseResults

	class ProviderBase
		attr_accessor :date, :houses
		
		def houses
			@houses ||= []
		end
		
	end
end