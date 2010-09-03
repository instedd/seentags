class ReportSet < ActiveRecord::Base
  belongs_to :account
  has_many :reports
  
  validates_presence_of :name, :account
  validates_uniqueness_of :name, :scope => :account_id, :message => 'has already been used by another report set in the account'

  before_create :generate_submit_url_key

  private

  def generate_submit_url_key
    self.submit_url_key = Guid.new.to_s
  end
end
