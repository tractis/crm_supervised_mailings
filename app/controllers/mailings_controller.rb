class MailingsController < ApplicationController
  before_filter :require_user
  before_filter :set_current_tab
  before_filter :auto_complete, :only => :auto_complete
  after_filter  :update_recently_viewed, :only => :show

  # GET /mailings
  # GET /mailings.xml                                                   HTML
  #----------------------------------------------------------------------------
  def index
    @mailings = get_mailings(:page => params[:page])

    respond_to do |format|
      format.html # index.html.haml
      format.js   # index.js.rjs
      format.xml  { render :xml => @mailings }
    end
  end

  # GET /mailings/1
  # GET /mailings/1.xml
  #----------------------------------------------------------------------------
  def show
    @mailing = Mailing.my(@current_user).find(params[:id])
    @mailing_mails = get_mailings_mails(:page => params[:page])
    @users = User.except(@current_user).all

    respond_to do |format|
      format.html # show.html.haml
      format.xml  { render :xml => @mailing }
    end
  end

  # GET /mailings/new
  # GET /mailings/new.xml                                               AJAX
  #----------------------------------------------------------------------------
  def new
    @mailing = Mailing.new(:user => @current_user, :access => Setting.default_access)
    @users = User.except(@current_user).all
    
    respond_to do |format|
      format.js   # new.js.rjs
      format.xml  { render :xml => @mailing }
    end
  end

  # GET /mailings/1/edit                                                AJAX
  #----------------------------------------------------------------------------
  def edit
    @mailing = Mailing.my(@current_user).find(params[:id])
    @users = User.except(@current_user).all
    
    if params[:previous] =~ /(\d+)\z/
      @previous = Mailing.find($1)
    end

  rescue ActiveRecord::RecordNotFound
    @previous ||= $1.to_i
    respond_to_not_found(:js) unless @mailing
  end
  
  # POST /mailings/1/upload_attachment                                     HTML
  #----------------------------------------------------------------------------
  def upload_attachment
    
    @mailing = Mailing.my(@current_user).find(params[:id])
    @users = User.except(@current_user).all
    
    if params[:mailing] && params[:mailing][:attc]
      if @mailing.update_attributes(params[:mailing])
        flash[:notice] = "#{@mailing.attc_file_name} uploaded correctly"
      else
        flash[:error] = "Problem uploading attachment"
      end
    else
      flash[:error] = "You need to select a file to upload"
    end
    
    redirect_to mailing_path(@mailing)
    
  end

  # GET /mailings/1/attachment                                            HTML
  #----------------------------------------------------------------------------  
  def attachment
    @mailing = Mailing.my(@current_user).find(params[:id])
    
    if @mailing.attc?
      send_file "#{RAILS_ROOT}/files/supervised_mailings/attachments/#{@mailing.id}/#{@mailing.attc_file_name}", :type => @mailing.attc_content_type, :filename=> @mailing.attc_file_name, :disposition => 'attachment'      
    else
      flash[:notice] = "Attachment not found"
      redirect_to mailing_path(@mailing)
    end    
  end
  
  # GET /mailings/1/start                                                AJAX
  #----------------------------------------------------------------------------
  def start
    @mailing = Mailing.my(@current_user).find(params[:id])
    @mailing_mails = get_mailings_mails(:page => params[:page], :filter => "ready")

    if @mailing_mails.blank?
      flash[:notice] = t :no_mails_to_send
      render :update do |page| 
        page.redirect_to(@mailing)
      end      
    else
      @mailing_mail = Mailing.check_and_update_mail_placeholders(@mailing_mails.first, @mailing, true)
      @users = User.except(@current_user).all
      render :template => "mailing_mails/edit.js.rjs"
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js) unless @mailing
  end

  # POST /mailings
  # POST /mailings.xml                                                  AJAX
  #----------------------------------------------------------------------------
  def create   
    @mailing = Mailing.new(params[:mailing])
    @users = User.except(@current_user).all

    respond_to do |format|
      if @mailing.save_with_permissions(params[:users])
        if params[:mailing_related_source]
          model = params[:mailing_related_source].singularize.camelize
          query = session[:"#{params[:mailing_related_source]}_current_query"]
          insert_mails(@mailing, model, query) 
        end       
        @mailings = get_mailings
        format.js   # create.js.rjs
        format.xml  { render :xml => @mailing, :status => :created, :location => @mailing }
      else
        format.js   # create.js.rjs
        format.xml  { render :xml => @mailing.errors, :status => :unprocessable_entity }
      end
    end   
  end

  # PUT /mailings/1
  # PUT /mailings/1.xml                                                 AJAX
  #----------------------------------------------------------------------------
  def update
    @mailing = Mailing.my(@current_user).find(params[:id])
    
    respond_to do |format|
      if @mailing.update_with_permissions(params[:mailing], params[:users])

        check_mails
        
        format.js   # update.js.rjs
        format.xml  { head :ok }
      else
        @users = User.except(@current_user).all
        format.js   # update.js.rjs
        format.xml  { render :xml => @mailing.errors, :status => :unprocessable_entity }
      end
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :xml)
  end

  # GET /mailings/1/check                                              HTML
  #----------------------------------------------------------------------------
  def check

    @mailing = Mailing.my(@current_user).find(params[:id])
    check_mails
    redirect_to(@mailing)

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :xml)
  end

  # GET /mailings/1/confirm                                             AJAX
  #----------------------------------------------------------------------------
  def confirm
    @mailing = Mailing.find(params[:id])

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :xml)
  end

  # DELETE /mailings/1
  # DELETE /mailings/1.xml                                              AJAX
  #----------------------------------------------------------------------------
  def destroy
    @mailing = Mailing.my(@current_user).find(params[:id])
    @mailing.destroy if @mailing

    respond_to do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
      format.xml  { head :ok }
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :js, :xml)
  end 

  # GET /mailings/search/query                                             AJAX
  #----------------------------------------------------------------------------
  def search
    @mailings = get_mailings(:query => params[:query], :page => 1)

    respond_to do |format|
      format.js   { render :action => :index }
      format.xml  { render :xml => @mailings.to_xml }
    end
  end

  # GET /mailings/options                                                 AJAX
  #----------------------------------------------------------------------------
  def options
    unless params[:cancel].true?
      @per_page = @current_user.pref[:mailings_per_page] || Mailing.per_page
      @sort_by  = @current_user.pref[:mailings_sort_by]  || Mailing.sort_by
      @filter   = @current_user.pref[:mailings_filter]   || Mailing.filter
    end
  end

  # GET /mailings/options_mail                                             AJAX
  #----------------------------------------------------------------------------
  def options_mails
    @mailing = Mailing.my(@current_user).find(params[:related]) if params[:related]
    
    unless params[:cancel].true?
      @per_page_mails = @current_user.pref[:mailings_mail_per_page] || MailingMail.per_page
      @sort_by_mails  = @current_user.pref[:mailings_mail_sort_by]  || MailingMail.sort_by
      @filter_mails   = @current_user.pref[:mailings_mail_filter]   || MailingMail.filter
    end
  end

  # POST /mailings/redraw                                                 AJAX
  #----------------------------------------------------------------------------
  def redraw
    @current_user.pref[:mailings_per_page] = params[:per_page] if params[:per_page]
    @current_user.pref[:mailings_sort_by]  = Mailing::sort_by_map[params[:sort_by]] if params[:sort_by]
    @current_user.pref[:mailings_filter]   = params[:filter] if params[:filter]
    @mailings = get_mailings(:page => 1)
    render :action => :index
  end

  # POST /mailings/redraw_mails                                            AJAX
  #----------------------------------------------------------------------------
  def redraw_mails
    @mailing = Mailing.my(@current_user).find(params[:related])
    @users = User.except(@current_user).all      
    
    @current_user.pref[:mailing_mails_sort_by]  = MailingMail::sort_by_map[params[:sort_by]] if params[:sort_by]
    @current_user.pref[:mailing_mails_filter]   = params[:filter_mails] if params[:filter_mails]
    
    render :update do |page| 
      page.redirect_to(@mailing)
    end    
  end  
   
  private

  #----------------------------------------------------------------------------
  def get_mailings(options = { :page => nil, :query => nil })
    self.current_page = options[:page] if options[:page]
    self.current_query = options[:query] if options[:query]
    current_filter = @current_user.pref[:mailings_filter] || Mailing.filter

    records = {
      :user => @current_user,
      :order => @current_user.pref[:mailings_sort_by] || Mailing.sort_by
    }
    pages = {
      :page => current_page,
      :per_page => @current_user.pref[:mailings_per_page]
    }

    if current_query.blank?
      if current_filter.empty? || current_filter == "all"  
        Mailing.my(records)
      else
        Mailing.my(records).filter_by_status(current_filter)
      end
    else
      if current_filter.empty? || current_filter == "all"  
        Mailing.my(records).search(current_query)
      else  
        Mailing.my(records).search(current_query).filter_by_status(current_filter)
      end
    end.paginate(pages)

  end


  def get_mailings_mails(options = { :page => nil, :query => nil })
    self.current_page = options[:page] if options[:page]
    self.current_query = options[:query] if options[:query]
    
    current_filter = @current_user.pref[:mailing_mails_filter] || MailingMail.filter
    current_filter = options[:filter] if options[:filter]
    current_order = @current_user.pref[:mailing_mails_sort_by] || MailingMail.sort_by

    conditions = { :mailing_id => @mailing.id }
    conditions[:status] = current_filter if current_filter == "new" || current_filter == "sent"
    conditions[:needs_update] = true if current_filter == "needs_data"
    if current_filter == "ready"
      conditions[:needs_update] = false
      conditions[:status] = "new"
    end    

    MailingMail.find(:all, :conditions => conditions, :include => :mailable, :order => current_order)
  end
  
  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      @mailings = get_mailings
      if @mailings.blank?
        @mailings = get_mailings(:page => current_page - 1) if current_page > 1
        render :action => :index and return
      end
      # At this point render default destroy.js.rjs template.
    else # :html request
      self.current_page = 1 # Reset current page to 1 to make sure it stays valid.
      flash[:notice] = "#{t(:asset_deleted, @mailing.name)}"
      redirect_to(mailings_path)
    end
  end

  def check_mails
    
    @mailing_mails = MailingMail.find(:all, :conditions => { :mailing_id => @mailing.id, :status => "new" }, :include => :mailable)

    @mailing_mails.each do |mail|
      Mailing.check_and_update_mail_placeholders(mail, @mailing)
    end

  end

end