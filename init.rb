require "fat_free_crm"

FatFreeCRM::Plugin.register(:crm_supervised_mailings, initializer) do
          name "Fat Free CRM Supervised Mailings"
       authors "Tractis - https://www.tractis.com - Jose Luis Gordo Romero"
       version "0.9"
   description "Fat Free CRM Supervised Mailings"
  dependencies :haml, :simple_column_search, :will_paginate
           tab :text => "mailings", :url => { :controller => "mailings" }  
end

require "crm_supervised_mailings"