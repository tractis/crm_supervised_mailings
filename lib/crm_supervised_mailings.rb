require "crm_supervised_mailings/view_hooks"

require "dispatcher"

Dispatcher.to_prepare do

  # Extend :account/contact model to add :mailing_mails association.
  Account.send(:include, AccountMailingMailAssociations)
  Contact.send(:include, ContactMailingMailAssociations)
  
  # Make issues observable.
  ActivityObserver.instance.send :add_observer!, Mailing

end

# Make the mailings commentable.
CommentsController::COMMENTABLE = CommentsController::COMMENTABLE + %w(mailing_id)