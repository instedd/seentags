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
      Report.create!(:original => original, :report_set_id => @report_set.id)
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
  
  # Invoked with ajax
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
    report.corrected = true
    report.save!
  
    head :ok
  end
  
  def reset
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
    
    report.parsed = nil
    report.corrected = false
    report.save!
  
    redirect_to :controller => 'report_set', :action => :view, :id => report_set.id
  end

end