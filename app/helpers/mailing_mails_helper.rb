module MailingMailsHelper
  
  #----------------------------------------------------------------------------
  def get_asset_link(asset)
    link_to "#{asset.name} - #{asset.email}", asset
  end

  #----------------------------------------------------------------------------
  def get_asset_link_name(asset)
    link_to "#{asset.name}", asset
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
    link_to_remote(t(:send), :method => :get, :url => edit_mailing_mail_path(mailing_mail))
  end
  
  
  def mails_highlightable(id = nil,  color = {}, status = "sent")
    color = { :on => "seashell", :off => "white" }.merge(color)
    show = (id ? "$('#{id}').style.visibility='visible'" : "")
    hide = (id ? "$('#{id}').style.visibility='hidden'" : "")
    { :onmouseover => "this.style.background='#{color[:on]}'; #{show}",
      :onmouseout  => "this.style.background='#{color[:off]}'; #{hide}",
      :name        => status
    }
  end 
  
  #----------------------------------------------------------------------------
  def one_submit_only_and_next_mail(form)
    { :onsubmit => "$('next_mail').value = crm.get_next_mail(); $('#{form}_submit').disabled = true;" }
  end

  # Sidebar checkbox control for filtering mails by status.
  #----------------------------------------------------------------------------
  def mailing_mails_status_checkbox(status, count)
    checked = (session[:filter_by_mailing_mail_status] ? session[:filter_by_mailing_mail_status].split(",").include?(status.to_s) : count.to_i > 0)
    check_box_tag("status[]", status, checked, :onclick => remote_function(:url => filter_mailing_path(@mailing), :with => %Q/"status=" + $$("input[name='status[]']").findAll(function (el) { return el.checked }).pluck("value")/))
  end   
  
end