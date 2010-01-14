class ReportSetController < AuthenticatedController

  before_filter :check_login
  
  def new
    @report_set = flash[:report_set]
  end
  
  def create
    report_set = params[:report_set]
    
    if report_set.nil?
      redirect_to_home
      return
    end
    
    @report_set = ReportSet.new(report_set)
    @report_set.account_id = @account.id
    @report_set.name = report_set[:name]
    
    if !@report_set.save
      flash[:report_set] = @report_set
      redirect_to :action => :new
      return
    end
    
    flash[:notice] = 'Report Set was created'
    redirect_to_home
  end
  
  def view
    @report_set = ReportSet.find params[:id]
    if @report_set.nil? || @report_set.account_id != @account.id
      redirect_to_home
      return
    end
    
    @reports = Report.find_all_by_report_set_id @report_set.id
    @parsed = @reports.map{|x| Parser.new(x.parsed).parse()}
    
    know = Knowledge.new @parsed
    know.apply_recursively_to @parsed
    know.simplify @parsed
    
    @reports.each_index do |i|
      @reports[i].parsed = @parsed[i].to_s
    end
  end
  
  def edit
    @report_set = ReportSet.find params[:id]
    if @report_set.nil? || @report_set.account_id != @account.id
      redirect_to_home
      return
    end
    
    if !flash[:report_set].nil?
      @report_set = flash[:report_set]
    end
  end
  
  def update
    report_set = params[:report_set]
    
    if report_set.nil?
      redirect_to_home
      return
    end
    
    @report_set = ReportSet.find params[:id]
    if @report_set.nil? || @report_set.account_id != @account.id
      redirect_to_home
      return
    end
    
    @report_set.name = report_set[:name]
    
    if !@report_set.save
      flash[:report_set] = @report_set
      redirect_to :action => :edit
      return
    end
    
    flash[:notice] = 'Report Set was updated'
    redirect_to_home
  end
  
  def delete
    @report_set = ReportSet.find params[:id]
    if @report_set.nil? || @report_set.account_id != @account.id
      redirect_to_home
      return
    end
    
    @report_set.delete
    
    flash[:notice] = 'Report Set was deleted'
    redirect_to_home
  end

end