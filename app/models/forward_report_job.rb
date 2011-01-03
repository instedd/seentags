require 'net/http'
require 'uri'

class ForwardReportJob
  attr_reader :report_id
  
  def initialize(report_id)
    @report_id = report_id
  end
  
  def perform
    # Find report
    report = Report.find @report_id
    
    # Construct Knowledge and parse reports
    reports = Report.find_all_by_report_set_id report.report_set_id
    parsed = Report.parse_all reports

    know = Knowledge.new parsed
    know.apply_recursively_to parsed
    know.simplify parsed
    know.unify_labels parsed
    
    # Select the report we are interested in
    report = reports.select{|x| x.id == report.id}.first
    
    # Callback Url
    url = URI.parse report.report_set.url_callback
    
    # Do a callback for each parsed report
    report.parsed.each do |parsed_report|
      Net::HTTP.post_form url, parsed_report.to_h
    end
  end
end