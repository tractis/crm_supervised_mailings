module LeadMailingMailAssociations
  
  def self.included(base)
    base.class_eval do
      has_many :mailings_mails, :dependent => :destroy, :as => :mailable
      has_many :mailings, :through => :mailing_mails
    end
  end

end
