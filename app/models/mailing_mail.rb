class MailingMail < ActiveRecord::Base
  belongs_to :mailing
  belongs_to :mailable, :polymorphic => true
  
  def self.statuses
    ["new", "rejected", "sent"]
  end  
end
