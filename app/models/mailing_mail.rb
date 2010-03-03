class MailingMail < ActiveRecord::Base
  belongs_to :mailing
  belongs_to :mailable, :polymorphic => true
  belongs_to  :user  

  acts_as_paranoid
  sortable :by => [ "status ASC", "created_at DESC", "updated_at DESC" ], :default => "status ASC"
  
  def self.statuses
    ["new", "sent"]
  end

  # Default values provided through class methods.
  #----------------------------------------------------------------------------
  def self.per_page ; 20     ; end
  def self.filter ; "new" ; end

end
