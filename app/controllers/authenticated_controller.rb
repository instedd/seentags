class AuthenticatedController < ApplicationController

  def check_login
    if session[:account_id].nil?
      redirect_to :action => :index
      return
    end
    
    @account_id = session[:account_id]
    @account = Account.find_by_id @account_id
  end
  
  def redirect_to_home
    redirect_to :controller => :home, :action => :home
  end

end