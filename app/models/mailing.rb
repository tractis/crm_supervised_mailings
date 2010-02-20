class Mailing < ActiveRecord::Base
  has_many    :mailing_mails, :dependent => :destroy
  belongs_to  :user
  
  simple_column_search :name, :match => :middle, :escape => lambda { |query| query.gsub(/[^\w\s\-\.']/, "").strip }
  uses_user_permissions
  acts_as_paranoid
  sortable :by => [ "name ASC", "created_at DESC", "updated_at DESC" ], :default => "created_at DESC"  

  validates_presence_of :name
  validates_presence_of :subject, :on => :update
  validates_presence_of :body, :on => :update
  validates_uniqueness_of :name
  validate :users_for_shared_access
  
  def self.statuses
    ["open", "finished"]
  end

  def self.general_placeholders
    [:name, :email, :phone, :fax]
  end

  def self.accounts_placeholders
    [:website]
  end

  def self.contacts_placeholders
    [:first_name, :last_name, :title, :department, :mobile, :blog]
  end

  def self.leads_placeholders
    [:first_name, :last_name, :title, :department, :mobile, :blog]
  end

  def self.show_ph(placeholder)
    "[#{placeholder.to_s}]]"
  end
  
  named_scope :open, :conditions => "status='open'"

  private
  # Make sure at least one user has been selected if the account is being shared.
  #----------------------------------------------------------------------------
  def users_for_shared_access
    errors.add(:access, :share_account) if self[:access] == "Shared" && !self.permissions.any?
  end
  
end
