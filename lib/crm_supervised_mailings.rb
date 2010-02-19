require "crm_supervised_mailings/crm_supervised_mailings_view_helpers"
require "crm_supervised_mailings/crm_supervised_mailings_view_hooks"
require "crm_supervised_mailings/crm_supervised_mailings_controller_actions"

require "dispatcher"

Dispatcher.to_prepare do

  # Extend :account/contact model to add :mailing_mails association.
  Account.send(:include, AccountMailingMailAssociations)
  Contact.send(:include, ContactMailingMailAssociations)
  
  # Make issues observable.
  ActivityObserver.instance.send :add_observer!, Mailing

end