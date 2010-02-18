class MailingMailsController < ApplicationController
  before_filter :require_user

  # GET /mailing_mails/1/edit                                                      AJAX
  #----------------------------------------------------------------------------
  def edit
    @mailing_mail = MailingMail.find(params[:id])
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

    respond_to do |format|
      if @mailing_mail.update_attributes(params[:mailing_mail])
        format.js   # update.js.rjs
        format.xml  { head :ok }
      else
        format.js   # update.js.rjs
        format.xml  { render :xml => @mailing_mail.errors, :status => :unprocessable_entity }
      end
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
  
  # PUT /tasks/1/complete
  # PUT /leads/1/complete.xml                                              AJAX
  #----------------------------------------------------------------------------
#  def complete
#    @task = Task.tracked_by(@current_user).find(params[:id])
#    @task.update_attributes(:completed_at => Time.now, :completed_by => @current_user.id) if @task
#
#    # Make sure bucket's div gets hidden if it's the last completed task in the bucket.
#    if Task.bucket_empty?(params[:bucket], @current_user)
#      @empty_bucket = params[:bucket]
#    end
#
#    update_sidebar unless params[:bucket].blank?
#    respond_to do |format|
#      format.js   # complete.js.rjs
#      format.xml  { head :ok }
#    end
#
#  rescue ActiveRecord::RecordNotFound
#    respond_to_not_found(:js, :xml)
#  end

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
