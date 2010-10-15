require 'test_helper'

class ForwardReportJobTest < ActiveSupport::TestCase

  include Mocha::API
  
  def setup
    @report_id = 1
    @report = mock()
    @report_set = mock()
    Report.stubs(:find).with(@report_id).returns(@report)
    @report.stubs(:report_set).returns(@report_set)
    @report.stubs(:parsed).returns('parsed content')
    @report_set.stubs(:url_callback).returns('http://www.domain.com/some/url')
    
    @job = ForwardReportJob.new @report_id
  end
  
  test "should return report id" do
    assert_equal @report_id, @job.report_id
  end

  test "should perform a post with parsed report" do
    request = mock('Net::HTTPRequest')
    response = mock('Net::HTTPResponse')
      
    Net::HTTP.expects(:new).with('www.domain.com', 80).returns(request)
    request.expects(:post).with("/some/url", @report.parsed).returns(response)
    
    res = @job.perform
    
    assert_equal response, res
  end
  
end
