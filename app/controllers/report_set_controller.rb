class ReportSetController < AuthenticatedController

  before_filter :check_login, :except => :incoming
  before_filter :check_report_set, :only => [:view, :edit, :update, :delete, :download_as_csv]

  skip_before_action :verify_authenticity_token, :only => [:incoming]

  def new
    @report_set = flash[:report_set]
  end

  def create
    report_set = params.permit![:report_set]

    if report_set.nil?
      redirect_to_home
      return
    end

    @report_set = ReportSet.new(report_set)
    @report_set.account_id = @account.id
    @report_set.name = report_set[:name]
    @report_set.url_callback = report_set[:url_callback]

    if !@report_set.save
      flash[:report_set] = @report_set
      redirect_to :action => :new
      return
    end

    flash[:notice] = 'Report Set was created'
    redirect_to_home
  end

  def view
    @reports = Report.find_all_by_report_set_id @report_set.id
    @parsed = Report.parse_all @reports

    know = Knowledge.new @parsed
    know.apply_recursively_to @parsed
    know.simplify @parsed
    know.unify_labels @parsed
  end

  def edit
    @report_set = flash[:report_set ]if flash[:report_set]
  end

  def update
    report_set = params.permit![:report_set]
    return redirect_to_home unless report_set

    @report_set.name = report_set[:name]
    @report_set.url_callback = report_set[:url_callback]

    if !@report_set.save
      flash[:report_set] = @report_set
      return redirect_to :action => :edit
    end

    flash[:notice] = 'Report Set was updated'
    redirect_to_home
  end

  def delete
    @report_set.destroy

    flash[:notice] = 'Report Set was deleted'
    redirect_to_home
  end

  def download_as_csv
    @reports = Report.find_all_by_report_set_id @report_set.id
    @parsed = Report.parse_all @reports do |report, parsed|
      parsed.add('created_at', report.created_at.to_s)
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

    @report_set = ReportSet.find_by_submit_url_key params.permit![:key]

    if @report_set.nil?
      return render :text => 'report set not found', :status => 404
    end

    metadata = request.query_parameters.map { |k,v|
      k == 'action' ? '' : "#{k}: \"#{v}\", "
    }.join

    if request.content_type == 'application/x-www-form-urlencoded'
      body = params.permit!['body'].presence || request.raw_post
    else
      body = request.raw_post()
    end
    original = metadata + (body || "")
    if body.blank?
      render :text => 'post body not specified or blank', :status => 500
    else
      report = Report.create!(:original => original, :report_set_id => @report_set.id)
      enqueue_callback(report)
      render :text => "ID: #{report.id}"
    end
  end

  private

  def check_report_set
    @report_set = ReportSet.find params.permit![:id]
    return redirect_to_home unless @report_set && @report_set.account_id == @account.id
    true
  end

  def enqueue_callback(report)
    return unless @report_set.has_callback?
    Delayed::Job.enqueue ForwardReportJob.new(report.id)
  end

end
