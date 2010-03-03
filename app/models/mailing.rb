class Mailing < ActiveRecord::Base
  has_many    :mailing_mails, :dependent => :destroy
  belongs_to  :user
  has_attached_file :attc, :url  => "/mailings/:id/attachment", :path => ":rails_root/files/supervised_mailings/attachments/:id/:filename"
  
  simple_column_search :name, :match => :middle, :escape => lambda { |query| query.gsub(/[^\w\s\-\.']/, "").strip }
  uses_user_permissions
  acts_as_paranoid
  #sortable :by => [ "name ASC", "created_at DESC", "updated_at DESC" ], :default => "status DESC, mailings.created_at DESC"
  sortable :by => [ "name ASC", "created_at DESC", "updated_at DESC" ], :default => "created_at DESC"
  
  validates_presence_of :name
  validates_presence_of :subject, :on => :update
  validates_presence_of :body, :on => :update
  validates_uniqueness_of :name
  validate :users_for_shared_access
  #validates_attachment_size :attachment, :less_than => 5.megabytes

  # Default values provided through class methods.
  #----------------------------------------------------------------------------
  def self.per_page ; 20     ; end
  def self.filter ; "open" ; end
  
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
    "[[#{placeholder.to_s}]]"
  end
  
  named_scope :open, :conditions => "status='open'"
  named_scope :filter_by_status, lambda { |status| { :conditions => [ "status = ?", status ] } }
  
  #----------------------------------------------------------------------------
  def self.check_and_update_mail_placeholders(mail, mailing, back = false)
    # Generate the list of placeholders for the mail source, wihtout mail because this is checked manually and not depends on mailing text
    placeholders = self.get_placeholders(mail)

    # Detects placeholders on subject and body to check against the mail asset
    missing_placeholders = ""

    # Check email globally manually
    missing_placeholders += "(email) " if mail.mailable.email.blank?
    
    if back == true
      subject = mailing.subject
      body = mailing.body
    end
    
    ["subject", "body"].each do |field|
      placeholders.each do |ph|
        if mailing.send(field.to_sym).include? Mailing.show_ph(ph)
          missing_placeholders += "(#{field}-#{ph}) " if mail.mailable.send(ph.to_sym).blank?
          # Make placeholders replacements Replace if data back is needed and source field is not blank
          subject = subject.gsub(self.show_ph(ph), mail.mailable.send(ph.to_sym)) if back == true && !mail.mailable.send(ph.to_sym).blank? && field == "subject"
          body = body.gsub(self.show_ph(ph), mail.mailable.send(ph.to_sym)) if back == true && !mail.mailable.send(ph.to_sym).blank? && field == "body"
        end
      end
    end
      
    # Mark mails as need_update
    if missing_placeholders.empty? && mail.needs_update == true
      mail.needs_update = false
      mail.needs_update_help = ""
      mail.save      
    elsif !missing_placeholders.empty?
      mail.needs_update = true
      mail.needs_update_help = missing_placeholders
      mail.save
    end
    
    # Return transformed data without saving if needed
    if back == true
      mail.subject = subject
      mail.body = body
      return mail
    end    

  end
  
  #----------------------------------------------------------------------------
  def self.get_placeholders(mail)
    self.send("#{mail.mailable.class.to_s.downcase.pluralize}_placeholders") + self.general_placeholders
  end

  private
  # Make sure at least one user has been selected if the account is being shared.
  #----------------------------------------------------------------------------
  def users_for_shared_access
    errors.add(:access, :share_account) if self[:access] == "Shared" && !self.permissions.any?
  end
  
end
