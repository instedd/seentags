require 'test_helper'

class ReportSetControllerTest < ActionController::TestCase

  test "download as csv" do
    account = Account.create!(:name => 'acc', :password => 'pass', :password_confirmation => 'pass')
    report_set = ReportSet.create!(:account_id => account.id, :name => 'rep_set')
    reports = create_reports(report_set.id, 'one, two, three')
    
    get :download_as_csv, {:id => report_set.id}, {:account_id => account.id}
    
    assert_response :ok
    assert_equal(
      "?1, ?2, ?3\r\n" + 
      "one, two, three\r\n", 
      @response.body)
  end
  
  test "download as csv 2" do
    account = Account.create!(:name => 'acc', :password => 'pass', :password_confirmation => 'pass')
    report_set = ReportSet.create!(:account_id => account.id, :name => 'rep_set')
    reports = create_reports(report_set.id, 'label1: one, two, three', 'LABEL1: one, two, three')
    
    get :download_as_csv, {:id => report_set.id}, {:account_id => account.id}
    
    assert_response :ok
    assert_equal(
      "label1, ?1, ?2\r\n" + 
      "one, two, three\r\n" + 
      "one, two, three\r\n", 
      @response.body)
  end
  
  test "download as csv numbers" do
    account = Account.create!(:name => 'acc', :password => 'pass', :password_confirmation => 'pass')
    report_set = ReportSet.create!(:account_id => account.id, :name => 'rep_set')
    reports = create_reports(report_set.id, '1, 2, 3')
    
    get :download_as_csv, {:id => report_set.id}, {:account_id => account.id}
    
    assert_response :ok
    assert_equal(
      "?1, ?2, ?3\r\n" + 
      "1, 2, 3\r\n", 
      @response.body)
  end
  
  test "download as csv bug" do
    account = Account.create!(:name => 'acc', :password => 'pass', :password_confirmation => 'pass')
    report_set = ReportSet.create!(:account_id => account.id, :name => 'rep_set')
    reports = create_reports(report_set.id, 'disease: H1N1, yes, 40', 'H1N1, 30 no', 'confirmed: no, cholera, 50')
    
    get :download_as_csv, {:id => report_set.id}, {:account_id => account.id}
    
    assert_response :ok
    assert_equal(
      "confirmed, disease, no\r\n" +
      "yes, H1N1, 40\r\n" +
      ", H1N1, 30\r\n" +
      "no, cholera, 50\r\n",
      @response.body)
  end
  
end
