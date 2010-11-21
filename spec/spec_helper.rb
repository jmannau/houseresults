require 'house_results'

RSpec.configure do |config|
  
  config.before do
    PDFKit.any_instance.stubs(:wkhtmltopdf).returns(
      File.join(SPEC_ROOT,'..','bin','wkhtmltopdf')
    )
  end
  
end