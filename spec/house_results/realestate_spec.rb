require 'spec_helper'
include HouseResults

describe RealEstate do

	it 'should parse normally' do
		RealEstate.new.parse
	end

end