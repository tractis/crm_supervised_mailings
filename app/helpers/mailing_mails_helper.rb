module MailingMailsHelper
  
  #----------------------------------------------------------------------------
  def get_asset_link(asset)
    link_to "#{asset.name} - #{asset.email}", asset
  end
  
  #----------------------------------------------------------------------------
  def link_to_mail_delete(mailing_mail)
    link_to_remote(t(:yes_button), 
      :method => :delete,
      :url => mailing_mail_path(mailing_mail),
      :before => visual_effect(:highlight, dom_id(mailing_mail), :startcolor => "#ffe4e1")
    )
  end 
  
  #----------------------------------------------------------------------------
  def link_to_mail_confirm(mailing_mail)
    link_to_remote(t(:delete) + "?", :method => :get, :url => confirm_mailing_mail_path(mailing_mail))
  end

  #----------------------------------------------------------------------------
  def link_to_mail_edit(mailing_mail)
    link_to_remote(t(:edit), :method => :get, :url => edit_mailing_mail_path(mailing_mail))
  end

  #----------------------------------------------------------------------------
  def link_to_mail_edit(mailing_mail)
    link_to_remote(t(:edit), :method => :get, :url => edit_mailing_mail_path(mailing_mail))
  end
  
  #----------------------------------------------------------------------------
  def link_to_mail_edit(mailing_mail)
    link_to_remote(t(:edit), :method => :get, :url => edit_mailing_mail_path(mailing_mail))
  end
  
end