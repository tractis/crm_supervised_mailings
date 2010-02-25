ActionController::Routing::Routes.draw do |map| 
  map.resources :mailings, :has_many => :mailing_mails, :collection => { :search => :get, :auto_complete => :post, :options => :get, :options_mails => :get, :redraw => :post, :redraw_mails => :post }, :member => { :confirm => :get, :addmails => :get, :addtomailing => :get, :check => :get, :start => :get }
  map.resources :mailing_mails, :collection => { :search => :get, :auto_complete => :post, :options => :get, :redraw => :post }, :member => { :confirm => :get }
end