class ReportController < ApplicationController

  def reports
    reps = params[:reports].strip
    reps = reps.split("\n").select{|x| x.strip.length > 0}.map{|x| Parser.new(x).parse}
    know = Knowledge.new(reps)
    
    learned = true
    while learned
      learned = false
      reps.each{|rep| learned |= know.apply_to(rep)}
    end
      
    reps.each{|rep| rep.simplify!}
    
    render :json => reps.map{|x| x.to_s}
  end
  
end