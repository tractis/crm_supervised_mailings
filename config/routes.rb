ActionController::Routing::Routes.draw do |map| 
  map.resources :mailings, :has_many => [:mailing_mails, :comments], :collection => { :search => :get, :auto_complete => :post, :options => :get, :redraw => :post }, :member => { :confirm => :get, :addmails => :get }
  map.resources :mailing_mails, :collection => { :search => :get, :auto_complete => :post, :options => :get, :redraw => :post }, :member => { :confirm => :get }
end