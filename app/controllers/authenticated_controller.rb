class AuthenticatedController < ApplicationController

  def check_login
    if session[:account].nil?
      redirect_to :action => :index
      return
    end
    
    @account = session[:account]
  end
  
  def redirect_to_home
    redirect_to :controller => :home, :action => :home
  end

end