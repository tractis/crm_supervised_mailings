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
      begin
        new_email = MailingNotifier.create_simple(@current_user, @mailing_mail, @mailing, params[:mailing_mail][:subject],  @template.auto_link(@template.simple_format params[:mailing_mail][:body]))
        MailingNotifier.deliver(new_email)
        
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
      rescue Net::SMTPFatalError => e
        # Error sending email
        flash[:error] = e.to_s
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
  
end
