require 'test_helper'

class ReportSetTest < ActiveSupport::TestCase
  
  def setup
    @report_set = ReportSet.new :name => "report name", :account => Account.new
  end
  
  test "should have a valid or empty callback " do
    @report_set.url_callback = 'invalid url'
    assert !@report_set.valid?
    @report_set.url_callback = nil
    assert @report_set.valid?
    @report_set.url_callback = 'http://www.domain.com/some/url'
    assert @report_set.valid?
  end
end
