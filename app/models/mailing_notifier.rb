class MailingNotifier < ActionMailer::Base
  
  def simple(user, mail, mailing, subject, body, mail_recipients)
    if mail_recipients && !mail_recipients.empty?
      recipients mail_recipients
    else
      recipients mail.mailable.email
    end
    
    from       user.email
    bcc        user.email
    subject    subject
    
    content_type    "multipart/alternative"
    part :content_type => "text/html", :body => body
    
    unless mailing.attc_file_name.blank?
      attachment :content_type => mailing.attc_content_type, :body => File.read("#{RAILS_ROOT}/files/supervised_mailings/attachments/#{mailing.id}/#{mailing.attc_file_name}")
    end
  end

end