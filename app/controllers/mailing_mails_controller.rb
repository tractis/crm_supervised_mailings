class MailingMailsController < ApplicationController
  before_filter :require_user

  # GET /mailing_mails/1/edit                                                      AJAX
  #----------------------------------------------------------------------------
  def edit
    @mail = MailingMail.find(params[:id])
    @mailing = Mailing.find(@mail.mailing_id)
    # Check and transform Transform data from source
    @mailing_mail = Mailing.check_and_update_mail_placeholders(@mail, @mailing, true) 
    
    @users = User.except(@current_user).all

    if params[:previous] =~ /(\d+)\z/
      @previous = MailingMail.find($1)
    end
  rescue ActiveRecord::RecordNotFound
    @previous ||= $1.to_i
    respond_to_not_found(:js) unless @mailing_mail
  end  
  
  # PUT /mailing_mails/1
  # PUT /mailing_mails/1.xml                                                       AJAX
  #----------------------------------------------------------------------------
  def update
    @mailing_mail = MailingMail.find(params[:id])
    @mailing = Mailing.find(@mailing_mail.mailing_id)
    @mailing_sim = Mailing.find(@mailing_mail.mailing_id)
    
    # Update subject and body
    @mailing_sim.subject = params[:mailing_mail][:subject]
    @mailing_sim.body = params[:mailing_mail][:body]
    
    # Check email for missing placeholders or email
    @mailing_mail = Mailing.check_and_update_mail_placeholders(@mailing_mail, @mailing_sim, true)
    
    if @mailing_mail.needs_update == false
      # Sending email
      send_response = send_mail(@mailing, @mailing_mail)
      if send_response == true
        # Making a comment on asset
        Comment.create(:title => "mailing_id_#{@mailing.id}", :user => @current_user, :commentable => @mailing_mail.mailable, :comment => "#{params[:mailing_mail][:subject]}\n\n#{params[:mailing_mail][:body]}")    
    
        # Now saving with status sent and sent_at date
        params[:mailing_mail][:status] = "sent"
        params[:mailing_mail][:sent_at] = Time.now.strftime('%Y-%m-%d %H:%M:%S')
        
        respond_to do |format|
          if @mailing_mail.update_attributes(params[:mailing_mail])            
            unless params[:next_mail].blank? || params[:next_mail] == "0"
              @mail = MailingMail.find(params[:next_mail].to_i)
              # Check and transform Transform data from source
              @mailing_mail_next = Mailing.check_and_update_mail_placeholders(@mail, @mailing, true)               
            end
            
            format.js   # update.js.rjs
            format.xml  { head :ok }
          else
            format.js   # update.js.rjs
            format.xml  { render :xml => @mailing_mail.errors, :status => :unprocessable_entity }
          end
        end
      else
        # Error sending email
        flash[:notice] = send_response
        #redirect_to(mailings_path)
        render :update do |page| 
          page.redirect_to(@mailing)
        end
      end
    else
      # Mail has placeholders, return to edit updated
      @users = User.except(@current_user).all      
      render :action => "edit"
    end
  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :xml)
  end

  # GET /mailing_mails/1/confirm                                             AJAX
  #----------------------------------------------------------------------------
  def confirm
    @mailing_mail = MailingMail.find(params[:id])

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :xml)
  end

  # DELETE /mailing_mails/1
  # DELETE /mailing_mails/1.xml                                              AJAX
  #----------------------------------------------------------------------------
  def destroy
    @mailing_mail = MailingMail.find(params[:id])
    @mailing_mail.destroy if @mailing_mail

    respond_to do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
      format.xml  { head :ok }
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :js, :xml)
  end

private
  #----------------------------------------------------------------------------
  def get_mailing_mails
    MailingMail.find(:all)
  end
  
  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      @mailing_mails = get_mailing_mails
      if @mailing_mails.blank?
        @mailing_mails = get_mailing_mails(:page => current_page - 1) if current_page > 1
        render :action => :index and return
      end
      # At this point render default destroy.js.rjs template.
    else # :html request
      self.current_page = 1 # Reset current page to 1 to make sure it stays valid.
      flash[:notice] = "#{t(:asset_deleted, @mailing_mail.name)}"
      redirect_to(mailing_mails_path)
    end
  end 
  
  def send_mail(mailing, mail)
    require 'gmail'
    
    #folder = "crm_mailings" if mailing.sent_folder.blank?
    subject = params[:mailing_mail][:subject]
    body = params[:mailing_mail][:body]
    #TODO: add folder label to message
    #TODO: Add atachments
    #require 'ruby-debug';debugger    
    
    begin
      gmail = Gmail.new(@current_user.pref[:google_account], @current_user.pref[:google_password]) do |g|
        new_email = MIME::Message.generate
        new_email.to mail.mailable.email
        new_email.subject subject
        plain, html = new_email.generate_multipart('text/plain', 'text/html')
        plain.content = body
        html.content = body
        #new_email.attach_file('some_image.dmg')
        g.send_email(new_email)
        #gmail_email.move_to(folder)
      end
      return true
    rescue Net::IMAP::NoResponseError => ex
      return ex.message
    end
  end
end
