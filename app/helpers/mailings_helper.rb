module MailingsHelper

  #----------------------------------------------------------------------------
  def link_to_confirm(mailing)
    link_to_remote(t(:delete) + "?", :method => :get, :url => confirm_mailing_path(mailing))
  end

  #----------------------------------------------------------------------------
  def link_to_delete(mailing)
    link_to_remote(t(:yes_button), 
      :method => :delete,
      :url => mailing_path(mailing),
      :before => visual_effect(:highlight, dom_id(mailing), :startcolor => "#ffe4e1")
    )
  end
  
end