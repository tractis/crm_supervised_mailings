//----------------------------------------------------------------------------
crm.get_next_mail = function(){
  mails = document.getElementsByName("pending");
  if (mails.length<2)
  {
    return 0;
  } else {
  	// return sencond mail because own mail is not rendered when called
	return mails[1].id.substring(13);
  }
}