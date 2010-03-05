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

  #----------------------------------------------------------------------------
  def get_asset_link(asset)
    link_to "#{asset.name} - #{asset.email}", asset
  end

  #----------------------------------------------------------------------------
  def get_asset_link_name(asset)
    link_to "#{asset.name}", asset
  end    
  
  #----------------------------------------------------------------------------
  def link_to_mail_confirm(mailing_mail)
    link_to_remote(t(:delete) + "?", :method => :get, :url => confirm_mailing_mail_path(mailing_mail))
  end

  #----------------------------------------------------------------------------
  def link_to_mail_edit(mailing_mail)
    link_to_remote(t(:send), :method => :get, :url => edit_mailing_mail_path(mailing_mail))
  end
  
  #----------------------------------------------------------------------------
  def link_to_mail_delete(mailing_mail)
    link_to_remote(t(:yes_button), 
      :method => :delete,
      :url => mailing_mail_path(mailing_mail),
      :before => visual_effect(:highlight, dom_id(mailing_mail), :startcolor => "#ffe4e1")
    )
  end

  # Ajax helper to refresh current index page once the user selects an option.
  #----------------------------------------------------------------------------
  def redraw_mails(option, value, mailing)
    if value.is_a?(Array)
      param, value = value.first, value.last
    end
    remote_function(
      :url       => send("redraw_mails_#{controller.controller_name}_path"),
      :with      => "{ #{option}: '#{param || value}', 'related': #{mailing} }",
      :condition => "$('#{option}').innerHTML != '#{value}'",
      :loading   => "$('#{option}').update('#{value}'); $('loading').show()",
      :complete  => "$('loading').hide()"
    )
  end
  
  #----------------------------------------------------------------------------
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
  
end