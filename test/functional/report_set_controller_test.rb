require 'test_helper'

class ReportSetControllerTest < ActionController::TestCase

  test "download as csv" do
    account = Account.create!(:name => 'acc', :password => 'pass', :password_confirmation => 'pass')
    report_set = ReportSet.create!(:account_id => account.id, :name => 'rep_set')
    reports = create_reports(report_set.id, 'one, two, three')
    
    get :download_as_csv, {:id => report_set.id}, {:account_id => account.id}
    
    assert_response :ok
    assert_equal(
      "created_at, ?1, ?2, ?3\r\n" + 
      "#{reports[0].created_at.to_s}, one, two, three\r\n", 
      @response.body)
  end
  
  test "download as csv 2" do
    account = Account.create!(:name => 'acc', :password => 'pass', :password_confirmation => 'pass')
    report_set = ReportSet.create!(:account_id => account.id, :name => 'rep_set')
    reports = create_reports(report_set.id, 'label1: one, two, three', 'LABEL1: one, two, three')
    
    get :download_as_csv, {:id => report_set.id}, {:account_id => account.id}
    
    assert_response :ok
    assert_equal(
      "created_at, label1, ?1, ?2\r\n" + 
      "#{reports[0].created_at.to_s}, one, two, three\r\n" + 
      "#{reports[1].created_at.to_s}, one, two, three\r\n", 
      @response.body)
  end
  
  test "download as csv numbers" do
    account = Account.create!(:name => 'acc', :password => 'pass', :password_confirmation => 'pass')
    report_set = ReportSet.create!(:account_id => account.id, :name => 'rep_set')
    reports = create_reports(report_set.id, '1, 2, 3')
    
    get :download_as_csv, {:id => report_set.id}, {:account_id => account.id}
    
    assert_response :ok
    assert_equal(
      "created_at, ?1, ?2, ?3\r\n" + 
      "#{reports[0].created_at.to_s}, 1, 2, 3\r\n", 
      @response.body)
  end
  
  test "download as csv bug" do
    account = Account.create!(:name => 'acc', :password => 'pass', :password_confirmation => 'pass')
    report_set = ReportSet.create!(:account_id => account.id, :name => 'rep_set')
    reports = create_reports(report_set.id, 'disease: H1N1, yes, 40', 'H1N1, 30 no', 'confirmed: no, cholera, 50')
    
    get :download_as_csv, {:id => report_set.id}, {:account_id => account.id}
    
    assert_response :ok
    assert_equal(
      "confirmed, created_at, disease, no\r\n" +
      "yes, #{reports[0].created_at.to_s}, H1N1, 40\r\n" +
      ", #{reports[1].created_at.to_s}, H1N1, 30\r\n" +
      "no, #{reports[2].created_at.to_s}, cholera, 50\r\n",
      @response.body)
  end
  
  test "incoming plain" do
    account = Account.create!(:name => 'acc', :password => 'pass', :password_confirmation => 'pass')
    report_set = ReportSet.create!(:account_id => account.id, :name => 'rep_set')
    
    @request.env['RAW_POST_DATA'] = 'one, two, three'
    @request.env['CONTENT_TYPE'] = 'text/plain'
    post :incoming, {:key => report_set.submit_url_key}
    
    reports = Report.all
    assert_equal 1, reports.length
    assert_equal 'one, two, three', reports[0].original
  end
  
  test "incoming form" do
    account = Account.create!(:name => 'acc', :password => 'pass', :password_confirmation => 'pass')
    report_set = ReportSet.create!(:account_id => account.id, :name => 'rep_set')
    
    @request.env['RAW_POST_DATA'] = 'baz=foo&body=one, two, three'
    @request.env['CONTENT_TYPE'] = 'application/x-www-form-urlencoded'
    post :incoming, {:key => report_set.submit_url_key, :baz => 'foo', :body => 'one, two, three'}
    
    reports = Report.all
    assert_equal 1, reports.length
    assert_equal 'one, two, three', reports[0].original
  end
  
end
