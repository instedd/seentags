class ReportController < AuthenticatedController

  before_filter :check_login

  def create
    @report_set = ReportSet.find params[:report_set_id]
    if @report_set.nil? || @report_set.account_id != @account.id
      redirect_to_home
      return
    end
    
    original = params[:report][:original].strip
    if !original.empty?
      parsed = Parser.new(original).parse.to_s
      Report.create(:original => original, :parsed => parsed, :report_set_id => @report_set.id)
    end
  
    redirect_to :controller => 'report_set', :action => :view, :id => @report_set.id
  end
  
  def delete
    report = Report.find_by_id params[:id]
    if report.nil?
      redirect_to_home
      return
    end
    
    report_set = ReportSet.find_by_id report.report_set_id
    if report_set.nil? || report_set.account_id != @account.id
      redirect_to_home
      return
    end
    
    report.delete
    
    redirect_to :controller => 'report_set', :action => :view, :id => report_set.id
  end
  
  def correct
    report = Report.find_by_id params[:id]
    if report.nil?
      redirect_to_home
      return
    end
    
    report_set = ReportSet.find_by_id report.report_set_id
    if report_set.nil? || report_set.account_id != @account.id
      redirect_to_home
      return
    end
    
    report.parsed = Parser.new(params[:text]).parse.to_s
    report.save!
  
    head :ok
  end

end