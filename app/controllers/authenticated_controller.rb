class AuthenticatedController < ApplicationController

  def check_login
    return redirect_to :action => :index unless session[:account_id]
    
    @account_id = session[:account_id]
    @account = Account.find_by_id @account_id

    return redirect_to :action => :index unless @account
  end
  
  def redirect_to_home
    redirect_to :controller => :home, :action => :home
  end

end
