class MailingMail < ActiveRecord::Base
  belongs_to :mailing
  belongs_to :mailable, :polymorphic => true
  belongs_to  :user  
  
  acts_as_paranoid 
  
  def self.statuses
    ["new", "rejected", "sent"]
  end  
end
