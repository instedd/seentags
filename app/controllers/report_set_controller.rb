class ReportSetController < AuthenticatedController

  before_filter :check_login, :except => :incoming
  
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
    @parsed = @reports.map{|x| Parser.new(x.parsed || x.original).parse()}
    
    know = Knowledge.new @parsed
    know.apply_recursively_to @parsed
    know.simplify @parsed
    know.unify_labels @parsed
    
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
  
  def download_as_csv
    @report_set = ReportSet.find params[:id]
    if @report_set.nil? || @report_set.account_id != @account.id
      redirect_to_home
      return
    end
    
    @reports = Report.find_all_by_report_set_id @report_set.id
    @parsed = @reports.map do |x|
      r = Parser.new(x.parsed || x.original).parse()
      r.add('created_at', x.created_at.to_s)
      r
    end
    
    know = Knowledge.new @parsed
    know.apply_recursively_to @parsed
    know.simplify @parsed
    know.unify_labels @parsed
    
    csv = know.to_csv(@parsed)
    now = Time.now.strftime("%Y_%m_%d-%H_%M_%S")
    send_data csv, :type => 'text/csv', :filename => @report_set.name + "-" + now + ".csv" 
  end

  def incoming    
    unless params[:key] && !params[:key].blank?
      render :text => 'key parameter not specified', :status => 500
      return
    end
    
    @report_set = ReportSet.find_by_submit_url_key params[:key]
    
    if @report_set.nil?
      render :text => 'report set not found', :status => 404
      return
    end
    
    metadata = request.query_parameters.map { |k,v| "#{k}: \"#{v}\", " }.join
    body = request.raw_post()
    original = metadata + body 
    if !body.empty?
      report = Report.create!(:original => original, :report_set_id => @report_set.id)
      render :text => "ID: #{report.id}"
    else
      render :text => 'post body not specified or blank', :status => 500
    end
  end

end
