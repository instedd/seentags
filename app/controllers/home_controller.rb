class HomeController < AuthenticatedController

  before_filter :check_login, :except => [:index, :login, :create_account]

  def index
    @account = Account.new
    @new_account = Account.new
  end

  def login
    acc = params.permit![:account]

    if acc.nil?
      redirect_to_home
      return
    end

    @account = Account.find_by_name acc[:name]
    if @account.nil? || !@account.authenticate(acc[:password])
      @account = Account.new(:name => acc[:name])
      @new_account = Account.new
      flash[:notice] = 'Invalid name/password'
      render 'index'
      return
    end

    session[:account_id] = @account.id
    redirect_to_home
  end

  def create_account
    acc = params.permit![:new_account]

    if acc.nil?
      redirect_to_home
      return
    end

    new_acc = Account.new(acc)
    if !new_acc.save
      new_acc.clear_password
      @account = Account.new
      @new_account = new_acc
      render 'index'
      return
    end

    session[:account_id] = new_acc.id
    redirect_to_home
  end

  def home
    @report_sets = @account.report_sets.order(:name)
  end

  def edit_account
    @account = flash[:account] if not flash[:account].nil?
  end

  def update_account
    acc = params.permit![:account]

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
      flash[:notice] = 'Account was updated'
      redirect_to_home
    end
  end

  def logoff
    session[:account] = nil
    redirect_to :action => :index
  end

end
