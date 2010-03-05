class MailingMailsController < ApplicationController
  before_filter :require_user
  before_filter :get_data_for_sidebar, :only => :update

  # GET /mailing_mails/1/edit                                                      AJAX
  #----------------------------------------------------------------------------
  def edit
    @mail = MailingMail.find(params[:id])
    @mailing = Mailing.find(@mail.mailing_id)
    # Check and transform Transform data from source
    @mailing_mail = Mailing.check_and_update_mail_placeholders(@mail, @mailing, true)
    
    @mailing_mail.mailable.email.blank? ? @recipient_number = 0 : @recipient_number = 1
    
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
    
    # Check recipients for accounts
    @recipients = []
    if @mailing_mail.mailable_type == "Account"      
      params[:recipients].each do |id, email|
        @recipients << email unless email.empty? || @recipients.include?(email)
      end
      @mailing_mail = Mailing.check_and_update_mail_placeholders(@mailing_mail, @mailing_sim, true, @recipients)
    else
      # Normal check email for missing placeholders or email
      @mailing_mail = Mailing.check_and_update_mail_placeholders(@mailing_mail, @mailing_sim, true)    
    end
    
    if @mailing_mail.needs_update == false
      # Sending email
      begin
        new_email = MailingNotifier.create_simple(@current_user, @mailing_mail, @mailing, params[:mailing_mail][:subject],  @template.auto_link(@template.simple_format params[:mailing_mail][:body]), @recipients)
        MailingNotifier.deliver(new_email)

        # Now saving with status sent, sent_at date and recipients
        params[:mailing_mail][:status] = "sent"
        params[:mailing_mail][:sent_at] = Time.now.strftime('%Y-%m-%d %H:%M:%S')
        
        if @recipients.empty?
          params[:mailing_mail][:recipients] = @mailing_mail.mailable.email
        else
          params[:mailing_mail][:recipients] = @recipients.join(", ")
        end        
        
        # Making a comment on asset
        Comment.create(:title => "mailing_id_#{@mailing.id}", :user => @current_user, :commentable => @mailing_mail.mailable, :comment => "#{t(:mail_to, params[:mailing_mail][:recipients])}\n#{t :subject}: #{params[:mailing_mail][:subject]}\n\n#{params[:mailing_mail][:body]}")    
        
        respond_to do |format|
          if @mailing_mail.update_attributes(params[:mailing_mail])            
            unless params[:next_mail].blank? || params[:next_mail] == "0"
              @mail = MailingMail.find(params[:next_mail].to_i)
              # Check and transform Transform data from source
              @mailing_mail_next = Mailing.check_and_update_mail_placeholders(@mail, @mailing, true)               
            end
            get_data_for_sidebar
            
            format.js   # update.js.rjs
            format.xml  { head :ok }
          else
            format.js   # update.js.rjs
            format.xml  { render :xml => @mailing_mail.errors, :status => :unprocessable_entity }
          end
        end
      rescue
        # Error sending email
        flash[:error] = t :error_sendig_mail
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
  
  # GET /mailing_mails/1/add_recipient                                       AJAX
  #----------------------------------------------------------------------------
  def add_recipient
    @mailing_mail = MailingMail.find(params[:id])
    
    @recipient_number = params[:related].to_i + 1
    
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

  #----------------------------------------------------------------------------
  def get_data_for_sidebar_before()
    @mails_stats_total = 0
    @mails_stats = {}
    @mails_stats[:sent] = 0
    @mails_stats[:ready] = 0
    @mails_stats[:needs_data] = 0
  end
  #----------------------------------------------------------------------------
  def get_data_for_sidebar()
    @mailing_mail_for_sidebar = MailingMail.find(params[:id])
    
    @mails_stats_total = MailingMail.count(:conditions => [ "mailing_id=?", @mailing_mail_for_sidebar.mailing_id ])
    
    @mails_stats = {}
    @mails_stats[:sent] = MailingMail.count(:conditions => [ "mailing_id=? and status=?", @mailing_mail_for_sidebar.mailing_id, "sent" ])
    @mails_stats[:ready] = MailingMail.count(:conditions => [ "mailing_id=? and status=? and needs_update=?", @mailing_mail_for_sidebar.mailing_id, "new", false ])
    @mails_stats[:needs_data] = MailingMail.count(:conditions => [ "mailing_id=? and status=? and needs_update=?", @mailing_mail_for_sidebar.mailing_id, "new", true ])
  end  
  
end
