Supervised Mailings plugin for Fat Free CRM
============

Supervised mass-mailing app for FatFreeCrm.

Installation
============

The plugin can be installed by running:

    script/plugin install git://github.com/tractis/crm_google_account_settings.git
    script/plugin install git://github.com/tractis/crm_supervised_mailings.git
    sudo gem install ruby-gmail -s http://gemcutter.org
    
Then run the following command:

    rake db:migrate:plugin NAME=crm_supervised_mailings

Then restart your web server.

Copyright (c) 2010 by Tractis (https://www.tractis.com), released under the MIT License