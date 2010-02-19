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
  $("mailing_disabled_title").show();
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