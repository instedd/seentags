require 'test_helper'

class ForwardReportJobTest < ActiveSupport::TestCase
  def setup
    @report_set = ReportSet.make :url_callback => "http://www.domain.com/some/url"
    @report1 = Report.make :report_set => @report_set, :original => "Disease:Malaria,Quantity:5"
    @report2 = Report.make :report_set => @report_set, :original => "HIV,6"

    @job = ForwardReportJob.new @report2.id
  end

  test "should return report id" do
    assert_equal @report2.id, @job.report_id
  end

  test "should perform a post with parsed report" do
    request = mock('Net::HTTPRequest')
    response = mock('Net::HTTPResponse')
    
    Net::HTTP.expects(:post_form).with(URI.parse("http://www.domain.com/some/url"), {"disease" => "HIV", "quantity" => 6})

    res = @job.perform
  end
  
  test "should perform N callbacks if report has N subreports" do
    report = Report.make :report_set => @report_set, :original => "Disease:HIV,Quantity:1,Disease:Malaria,Quantity:2"
    job = ForwardReportJob.new report.id
    
    request = mock('Net::HTTPRequest')
    response = mock('Net::HTTPResponse')
    
    Net::HTTP.expects(:post_form).with(URI.parse("http://www.domain.com/some/url"), {"Disease" => "HIV", "Quantity" => 1})
    Net::HTTP.expects(:post_form).with(URI.parse("http://www.domain.com/some/url"), {"Disease" => "Malaria", "Quantity" => 2})

    res = job.perform
  end
end
