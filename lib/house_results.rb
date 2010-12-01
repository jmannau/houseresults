module HouseResults
	
	require 'rubygems'

	require File.join(File.dirname(__FILE__), 'house_results/provider_base')
	require File.join(File.dirname(__FILE__), 'house_results/result_base')
	require File.join(File.dirname(__FILE__), 'house_results/providers/realestate')
	require File.join(File.dirname(__FILE__), 'house_results/providers/realestate_result')
	require File.join(File.dirname(__FILE__), 'house_results/providers/domain')
	require File.join(File.dirname(__FILE__), 'house_results/providers/domain_result')

end