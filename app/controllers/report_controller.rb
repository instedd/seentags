class ReportController < AuthenticatedController

  before_filter :check_login
  before_filter :check_report, :only => [:delete, :correct, :reset]

  def create
    @report_set = ReportSet.find params[:report_set_id]
    return redirect_to_home unless @report_set && @report_set.account_id == @account.id

    original = params[:report][:original].strip
    if original.present?
      Report.create!(:original => original, :report_set_id => @report_set.id)
    end

    redirect_to :controller => 'report_set', :action => :view, :id => @report_set.id
  end

  def delete
    @report.destroy

    redirect_to :controller => 'report_set', :action => :view, :id => @report_set.id
  end

  # Invoked with ajax
  def correct
    idx = params[:idx].to_i
    return redirect_to_home if idx < 0

    parsed = @report.parse
    return redirect_to_home unless idx < parsed.length

    current_parsed = Parser.parse(params[:text])

    new_parsed = []

    # Put parsed before idx
    0.upto(idx - 1) do |i|
      new_parsed << parsed[i]
    end

    # Put current parsed
    current_parsed.each{|p| new_parsed << p}

    # Put parsed after idx
    (idx + 1).upto(parsed.length - 1) do |i|
      new_parsed << parsed[i]
    end

    @report.parsed = new_parsed.map &:to_s
    @report.corrected = true
    @report.save!

    head :ok
  end

  def reset
    @report.parsed = nil
    @report.corrected = false
    @report.save!

    redirect_to :controller => 'report_set', :action => :view, :id => @report_set.id
  end

  private

  def check_report
    @report = Report.find_by_id params[:id]
    return redirect_to_home unless @report

    @report_set = @report.report_set
    return redirect_to_home unless @report_set && @report_set.account_id == @account.id
  end

end
