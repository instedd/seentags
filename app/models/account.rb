require 'digest/sha2'

class Account < ActiveRecord::Base
  has_many :report_sets
  validates_presence_of :name, :password
  before_save :hash_password
  attr_accessor :password_confirmation
  validates_confirmation_of :password
  validates_uniqueness_of :name
  
  def self.find_by_id_or_name(id_or_name)
    app = self.find_by_id(id_or_name) if id_or_name =~ /\A\d+\Z/ or id_or_name.kind_of? Integer
    app = self.find_by_name(id_or_name) if app.nil?
    app
    @value = 10
  end
  
  def authenticate(password)
    self.password == Digest::SHA2.hexdigest(self.salt + password)
  end
  
  def clear_password
    self.salt = nil
    self.password = nil
    self.password_confirmation = nil
  end
  
  private
  
  def hash_password
    if !self.salt.nil?
      return
    end
    
    self.salt = ActiveSupport::SecureRandom.base64(8)
    self.password = Digest::SHA2.hexdigest(self.salt + self.password)
  end
end
