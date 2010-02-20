class CrmSupervisedMailingsViewHooks < FatFreeCRM::Callback::Base
  
  ACTIONS_FOR_SHOW = <<EOS
- content_for :javascript do
  = render :file => "mailings/functions.js"
  
%br
%h4= get_supervised_mailings_translation('mailings')

.label
  %span#mailing_create_title
    create_new or <a href='#' onclick='crm.select_mailing(1); return false;'>select_existing</a>:
  %span#mailing_select_title
    <a href='#' onclick='crm.create_mailing(1); return false;'>create_new</a> or select_existing:
  %span#mailing_disabled_title :
    
= form_tag :action => "add_to_mailing"
= collection_select :mailing, :id, Mailing.my(@current_user).open, :id, :name, { :style => "width:150px; display:none;" }
= text_field(:mailing, :name, :style => "width:150px; display:none;")
:javascript
  crm.create_or_select_mailing(1);
= submit_tag "add"
EOS

  SM_JAVASCRIPT = <<EOS
// Hide mailing dropdown and show create new mailing edit field instead.
//----------------------------------------------------------------------------
crm.create_mailing = function(and_focus) {
  $("mailing_disabled_title").hide();
  $("mailing_select_title").hide();
  $("mailing_create_title").show();
  $("mailing_id").hide();
  $("mailing_id").disable();
  $("mailing_name").enable();
  $("mailing_name").clear();
  $("mailing_name").show();
  if (and_focus) {
    $("mailing_name").focus();
  }
}

// Hide create mailing edit field and show mailings dropdown instead.
//----------------------------------------------------------------------------
crm.select_mailing = function(and_focus) {
  $("mailing_disabled_title").hide();
  $("mailing_create_title").hide();
  $("mailing_select_title").show();
  $("mailing_name").hide();
  $("mailing_name").disable();
  $("mailing_id").enable();
  $("mailing_id").show();
  if (and_focus) {
    $("mailing_id").focus();
  }
}

// Show mailings dropdown and disable it to prevent changing the mailing.
//----------------------------------------------------------------------------
crm.select_existing_mailing = function() {
  $("mailing_create_title").hide();
  $("mailing_select_title").hide();
  $("mailingcrm_issues_disabled_title").show();
  $("mailing_name").hide();
  $("mailing_name").disable();
  $("mailing_id").disable();
  $("mailing_id").show();
}

//----------------------------------------------------------------------------
crm.create_or_select_mailing = function(selector) {
  if (selector !== true && selector > 0) {
    this.select_existing_mailing(); // disabled mailings dropdown
  } else if (selector) {
    this.create_mailing();          // create mailing edit field
  } else {
    this.select_mailing();          // mailings dropdown
  }
}
EOS

  #----------------------------------------------------------------------------
  def javascript_epilogue(view, context = {})
    SM_JAVASCRIPT
  end

  #----------------------------------------------------------------------------
  [ :account, :contact, :lead ].each do |model|

    define_method :"index_#{model}_sidebar_bottom" do |view, context|
      Haml::Engine.new(ACTIONS_FOR_SHOW).render(view, :model => context[model])
    end
      #view.controller.send(:render_to_string, :partial => "accounts/issues")
  end

end
