class ReportSet < ActiveRecord::Base
  @@url_regexp = Regexp.new('((?:http|https)(?::\\/{2}[\\w]+)(?:[\\/|\\.]?)(?:[^\\s"]*))', Regexp::IGNORECASE)
  
  belongs_to :account
  has_many :reports
  
  validates_presence_of :name, :account
  validates_uniqueness_of :name, :scope => :account_id, :message => 'has already been used by another report set in the account'
  validate :callback_is_url

  before_create :generate_submit_url_key
  
  def has_callback?
    return url_callback.present?
  end
  
  def generate_submit_url_key
    self.submit_url_key = Guid.new.to_s
  end
  
  private
  
  def callback_is_url
    return if url_callback.nil? || url_callback.empty?
    errors.add(:url_callback, "Callback must be a valid URL") if @@url_regexp.match(url_callback).nil?
  end
  
end
