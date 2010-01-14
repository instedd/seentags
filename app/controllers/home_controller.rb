class HomeController < AuthenticatedController

  before_filter :check_login, :except => [:index, :login, :create_account]

  def index
    if !session[:account].nil?
      redirect_to_home
      return
    end
  
    @account = flash[:account]
    @new_account = flash[:new_account]
  end
  
  def login
    acc = params[:account]
    
    if acc.nil?
      redirect_to_home
      return
    end
    
    @account = Account.find_by_name acc[:name]
    if @account.nil? || !@account.authenticate(acc[:password])
      flash[:account] = Account.new(:name => acc[:name])
      flash[:notice] = 'Invalid name/password'
      redirect_to :action => :index
      return
    end
    
    @account.clear_password
    
    session[:account] = @account
    redirect_to_home
  end
  
  def create_account
    acc = params[:new_account]
    
    if acc.nil?
      redirect_to_home
      return
    end
    
    new_acc = Account.new(acc)
    if !new_acc.save
      new_acc.clear_password
      flash[:new_account] = new_acc
      redirect_to :action => :index
      return
    end
    
    new_acc.clear_password
    
    session[:account] = new_acc
    redirect_to_home
  end
  
  def home
    @report_sets = ReportSet.find_all_by_account_id(@account.id, :order => :name)
  end
  
  def edit_account
    @account = flash[:account] if not flash[:account].nil?
  end
  
  def update_account
    acc = params[:account]
    
    if acc.nil?
      redirect_to_home
      return
    end
    
    exisiting_acc = Account.find @account.id
      
    if !acc[:password].chomp.empty?
      exisiting_acc.salt = nil
      exisiting_acc.password = acc[:password]
      exisiting_acc.password_confirmation = acc[:password_confirmation]
    end
    
    if !exisiting_acc.save
      exisiting_acc.clear_password
      flash[:account] = exisiting_acc
      redirect_to :action => :edit_account
    else    
      exisiting_acc.clear_password
      flash[:notice] = 'Account was updated'
      session[:account] = exisiting_acc
      redirect_to_home
    end
  end
  
  def logoff
    session[:account] = nil
    redirect_to :action => :index
  end

end