require 'net/http'
require 'uri'

class ForwardReportJob
  attr_reader :report_id
  
  def initialize(report_id)
    @report_id = report_id
  end
  
  def perform
    report = Report.find @report_id
    url = URI.parse report.report_set.url_callback
    
    request = Net::HTTP.new url.host, url.port
    response = request.post url.path, report.parsed
  end
end