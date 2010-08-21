class YachtsController < ApplicationController
  # GET /yachts  # GET /yachts.xml
  layout 'members'
  def index
    @yachts = Yacht.broker(session[:brokerid]).paginate :page => params[:page], :per_page => 15
    @categories = Category.find(:all)
  end

  # GET /yachts/1
  # GET /yachts/1.xml
  def show
    @yacht = Yacht.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @yacht }
    end
  end

  def sendtofriend
   @email = Email.new
  	render :layout => 'home'
  end
  
  def savesendtofriend
    @mailinfo = params[:email][:to]
    @friendlists = @mailinfo.split(",")
    for friendlist in @friendlists
      @email = Email.new
      @email.to = friendlist 
      @email.mail = params[:email][:mail]
      #@email.yacht_id = 1
    	@email.save
    end
    Email.update(@friendlists,params[:email][:mail])
    flash[:notice] = 'mail send'
      #UserMailer.deliver_send_to_friend(@friendlists,params[:email][:mail])
    redirect_to(sendtofriend_path)
  end

  def yachtdetailview
    (params[:tabdetail].blank?)?(session[:tabdetail] = 'specification'):(session[:tabdetail] = params[:tabdetail])
		@details = Yacht.find_by_id(params[:id])
		@showprofessional = User.find_by_id(session[:id])

		
		#flash[:notice] = @showprofessional
		#exit	
		#@owneremail = @details.owners_email
		if @details
		  @showprimary = @details.galleries.find(:first, :conditions=>["is_primary = ?",1])
		  (@details.key_selling_features.blank?)?(@keysellingfeatures=""):(@keysellingfeatures = @details.key_selling_features.split(','))
  		render :layout => 'home'
    else
      redirect_to '/home/index'
    end
  end
  
  def yachtdetailviewtab
    (params[:tabdetail].blank?)?(session[:tabdetail] = 'specification'):(session[:tabdetail] = params[:tabdetail])
		@details = Yacht.find_by_id(params[:id])
		if @details
		@showprimary = @details.galleries.find(:first, :conditions=>["is_primary = ?",1])
  		(@details.key_selling_features.blank?)?(@keysellingfeatures=""):(@keysellingfeatures = @details.key_selling_features.split(','))
	  	render :partial=> '/yachts/tabmoreinfo', :layout => false
    else
      render :text=>"could not find the id"
    end
  end
  
  def showprimary
    @previous=''
    (session[:pimage].blank?)?(@previous=''):(@previous=session[:pimage])
    if @previous != params[:current_id]
      @gallery = Gallery.find(params[:current_id])
      @yacht = Yacht.find(session[:yachtid])
      @yacht.filename=@gallery.filename
      @yacht.content_type=@gallery.content_type
      @yacht.image=@gallery.image
      @yacht.photo_small=@gallery.photo_small
      @yacht.photo_medium=@gallery.photo_medium
      @yacht.height=@gallery.height
      @yacht.width=@gallery.width
      session[:pimage] = params[:current_id]
      if @yacht.save
        @galleries = Gallery.update_all 'is_primary = 0', "is_primary='1' and yacht_id='#{session[:yachtid]}'"
        @gallery.is_primary = 1
        @gallery.save 
      end
    else
       session[:pimage] = params[:current_id]
    end
  end
  
  def yachtadditionaldetails
	@details = Yacht.find(params[:id])
  	render :partial => '/yachts/yachtadditionaldetails'
  end
  
  # GET /yachts/new
  # GET /yachts/new.xml
  def new
    @categories = Category.find(:all)
    @types = Type.find(:all)
    @manufacturers = Manufacturer.find(:all)
    @hulltypes = HullType.find(:all)
    @conditions = Condition.find(:all)
    @propellers = PropellerType.find(:all)
    @propellermaterials = PropellerMaterial.find(:all)
    @enginetypes = EngineType.find(:all)
    @enginedrives = EngineDrive.find(:all)
    @yacht = Yacht.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @yacht }
    end
  end
  
  def quickadd
    @yacht = Yacht.new
    render :layout => false
  end
  
  def addcaption
    (params[:caption].blank?)?(@caption=''):(@caption=params[:caption])
  end

  def show_image
    @photo = Yacht.find(:first,:conditions => ["id = ?",params[:id]])
	  image = @photo.photo_medium()
	  send_data(image, :type => "image/jpg",:disposition => 'inline')  
  end
  
  def show_medium_image
    @photo = Gallery.find(:first,:conditions => ["id = ?",params[:id]])
    image = @photo.photo_medium()
	 send_data(image, :type => "image/jpg",:disposition => 'inline')
  end
  
  def show_small_image
    @photo = Gallery.find(:first,:conditions => ["id = ?",params[:id]])
    image = @photo.photo_small()
	  send_data(image, :type => "image/jpg",:disposition => 'inline')  
  end

  # GET /yachts/1/edit
  def edit
    @categories = Category.find(:all)
    @types = Type.find(:all)
    @manufacturers = Manufacturer.find(:all)
    @hulltypes = HullType.find(:all)
    @conditions = Condition.find(:all)
    #@engineemakers = EngineMaker.find(:all)
    @propellers = PropellerType.find(:all)
    @propellermaterials = PropellerMaterial.find(:all)
    @enginetypes = EngineType.find(:all)
    @enginedrives = EngineDrive.find(:all)
    @yacht = Yacht.find(params[:id])
    session[:yachtid]=params[:id]
    session[:yachtmode]='Step One'
    redirect_to editinfo_path
  end
  
  def editinfo
    @keysellinfeatures = Keysellingfeature.find(:all, :conditions => "broker_id = '#{session[:brokerid]}'", :order => :name)
    @yacht = Yacht.find(session[:yachtid])
    
    if @yacht.country.blank?
      @yacht.country = 'United State'
    end
  end

  # POST /yachts
  # POST /yachts.xml
  def create
    @yacht = Yacht.new(params[:yacht])
    @yacht.status=params[:yacht_status]
    @yacht.broker_id = session[:brokerid]
    respond_to do |format|
      if @yacht.save
        session[:yachtid]=@yacht.id
        session[:yachtmode]='Key Selling Features'
        flash[:notice] = 'Yacht was successfully created.'
        
        #format.html { redirect_to(previewyachtdetail_path(session[:yachtid])) }
        format.html { redirect_to(editinfo_path) }
        format.xml  { render :xml => @yacht, :status => :created, :location => @yacht }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @yacht.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /yachts/1
  # PUT /yachts/1.xml
   
  def setstatus    
    @target_yacht = Yacht.find(params[:id])
    if @target_yacht.status == params[:status]
      @msg = "Yacht has been already saved as " + params[:status]
      render :update do |page|
   	    page[:loadingimage].hide
    	    page[:overlay].hide
    	    page.alert(@msg)
    	end
    else
      @target_yacht.status = params[:status]
      if @target_yacht.save
        @msg = "Yacht status has been saved as " + params[:status]
        @yachts = Yacht.broker(session[:brokerid]).paginate :page => params[:page], :per_page => 15
        render :update do |page|
    	    #page.replace_html "yachtstatus_"+params[:id], :partial=>'changedstatus'
    	    #page.replace_html "yachtstatuslist",:partial=>'/yachts/inventorylist'    	    
    	    page[:loadingimage].hide
    	    page[:overlay].hide
    	    page[:yachtstatuslist].replace_html :partial=>'/yachts/inventorylist'
    	    #page.alert(@msg)    	   
    	  end
    	  
    	  
      else
        @msg = "Please try again"
        render :update do |page|
          page[:loadingimage].hide
    	    page[:overlay].hide
          page.alert(@msg)
        end
     end
   end
  end
  
  def update
    @yacht = Yacht.find(params[:id])
    respond_to do |format|
      if @yacht.update_attributes(params[:yacht])
        flash[:notice] = 'Yacht was successfully updated.'
        format.html { redirect_to(@yacht) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @yacht.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def duplicateyacht
    @yacht = Yacht.new
    @source_yacht = Yacht.find(params[:id])
    @temp_yacht = @source_yacht.clone
    @yacht  = @temp_yacht
    @yacht.created_at=nil	
    @yacht.updated_at=nil
    @yacht.documentation_no = nil
    @yacht.status = "Inactive"
    @yacht.save
    flash[:notice]="Duplicate yacht has been succesfully created..Please check last yacht in listing"
    redirect_to yachts_path 
  end
  
  def updateyacht
    @keysellinglist = []
    @keysellinglistname = ''
    if params[:commit]
      session[:yachtmode] = params[:commit]
      if params[:yacht]
        
        if not params[:key_selling_features].blank?
          (params[:key_selling_features].blank?)?(@keysellingfeatures = ''):(@keysellingfeatures = params[:key_selling_features])
          if not params[:key_selling_features].blank?
            @keysellinglist << add_features(@keysellingfeatures)
            @keysellinglistname += session[:featurename]
            session[:featurename]=nil
          end
        end
        if not params[:yacht][:key_selling_features].blank?
          (params[:yacht][:key_selling_features].blank?)?(@keysellingfeatures = ''):(@keysellingfeatures = params[:yacht][:key_selling_features])
          if not params[:yacht][:key_selling_features].blank?
            @keysellinglist << add_features(@keysellingfeatures)
            (@keysellinglistname.blank?)?(@keysellinglistname=session[:featurename]):(@keysellinglistname+=","+session[:featurename])
            session[:featurename]=nil
          end
        end
      end
    end
	 @keysellinfeatures = Keysellingfeature.find(:all, :conditions => "broker_id = '#{session[:brokerid]}'", :order => :name)
    @yacht = Yacht.find(session[:yachtid])
    if params[:yacht]
      if not @keysellinglist.blank?
        @yacht.keysellingfeatures.clear
        for feature_id in @keysellinglist
          @yacht.keysellingfeatures << Keysellingfeature.find(feature_id)
        end
        params[:yacht][:key_selling_features] = @keysellinglistname
      end
    end
    if @yacht.update_attributes(params[:yacht])
      flash[:notice] = 'Yacht was successfully updated.'
      render :partial => 'editform'
    else
      render :action => "edit"
    end
  end

  def add_features(features)
    @totalfeatures = []
    @totalfeaturename = ''
    @features = features.split(",")
    for features in @features
      if features != ''
        @featureid = ''
        @featurename = ''
        @feature = features.lstrip.rstrip.gsub("_"," ")
        @query = Keysellingfeature.find(:all, :conditions => "name='#{@feature}' and broker_id = '#{session[:brokerid]}'")
        if @query.size == 0
            @keysellingfeature = Keysellingfeature.new
            @keysellingfeature.name = @feature
            @keysellingfeature.broker_id = session[:brokerid]
            @keysellingfeature.save
          @featureid = @keysellingfeature.id
          @featurename = @keysellingfeature.name
        else
          @featureid = @query[0].id
          @featurename = @query[0].name
        end
        @totalfeatures << @featureid.to_s
        (@totalfeaturename == '')?(@totalfeaturename = @featurename.to_s):(@totalfeaturename += ","+@featurename.to_s)
        session[:featurename] = @totalfeaturename
      end
    end
    
    return @totalfeatures
    
  end
  # DELETE /yachts/1
  # DELETE /yachts/1.xml
  def destroy
    @yacht = Yacht.find(params[:id]).update_attributes(:status=>'Archive')
    flash[:notice]="Yacht status has been saved as Archive."
    respond_to do |format|
      format.html { redirect_to(yachts_url) }
      format.xml  { head :ok }
    end
  end
  
  def yachtdetail_preview
    (params[:tabdetail].blank?)?(session[:tabdetail] = 'specification'):(session[:tabdetail] = params[:tabdetail])
		@details = Yacht.find_by_id(params[:id])
		
		if @details
		  @showprimary = @details.galleries.find(:first, :conditions=>["is_primary = ?",1])
		  (@details.key_selling_features.blank?)?(@keysellingfeatures=""):(@keysellingfeatures = @details.key_selling_features.split(','))
  		render :layout => 'home'
    else
      redirect_to '/home/index'
    end
  end

  def edityachtbasicinfo
    @yacht = Yacht.find_by_id(params[:id])
    render :update do |page|
      page.replace_html 'div_yachtbasicinfo',:partial=>'/yachts/editbasicinfo'
    end
  end  
  
  def updateyachtbasicinfo
    @details = Yacht.find_by_id(params[:id])
    @details.update_attributes(:name=>params[:yacht][:name],:making_year=>params[:yacht][:making_year],:city=>params[:yacht][:city],:state=>params[:yacht][:state],:country=>params[:yacht][:country],:model=>params[:yacht][:model],:price=>params[:yacht][:price])
    render :partial=>'/yachts/showbasicinfo'
  end
  
  def previewyachtdetailviewtab
    @gallery = Gallery.new
    
    (params[:tabdetail].blank?)?(session[:tabdetail] = 'specification'):(session[:tabdetail] = params[:tabdetail])
	  @details = Yacht.find_by_id(params[:id])
	 
 	 if @details
 	   @showprimary = @details.galleries.find(:first, :conditions=>["is_primary = ?",1])
 	   session[:yachtid] = @details.id
 	   @galleries = Gallery.find_all_by_yacht_id(session[:yacht_id]).paginate :page => @page, :per_page => 2 
      @primary_gallery_img = Gallery.find(:first,:conditions=>["is_primary=? and filename=? and yacht_id=?",1,@details.filename,@details.id])
      if @primary_gallery_img != nil
        session[:pimage] = @primary_gallery_img.id
      else
#       @primary_gallery_img = Gallery.find(:first,:conditions=>["yacht_id=?",@yacht_id])
        session[:pimage] = nil #@primary_gallery_img.id 
      end
  		(@details.key_selling_features.blank?)?(@keysellingfeatures=""):(@keysellingfeatures = @details.key_selling_features.split(','))
	  	render :partial=> '/yachts/previewtabmoreinfo', :layout => false
   else
      render :text=>"could not find the id"
    end
  end
  
  def editspecification
    @yacht = Yacht.find_by_id(params[:id])
    render :update do |page|
      page.replace_html 'div_specification',:partial=>'/yachts/editspecification'
    end
  end 
  
  def updatespecification
    @details = Yacht.find_by_id(params[:id])
    @details.update_attributes(:name=>params[:yacht][:name],:status=>params[:yacht][:status],:crusing_speed=>params[:yacht][:crusing_speed],:draft=>params[:yacht][:draft],:water=>params[:yacht][:water],:max_speed=>params[:yacht][:water],:max_speed=>params[:yacht][:max_speed],:owners_name=>params[:yacht][:owners_name],:total_hp=>params[:yacht][:total_hp],:beam=>params[:yacht][:beam],:fuel=>params[:yacht][:fuel],:berth=>params[:yacht][:berth],:loa=>params[:yacht][:loa],:documentation_no=>params[:yacht][:documentation_no],:cabins=>params[:yacht][:cabins],:holding_capacity=>params[:yacht][:holding_capacity],:engine_commins=>params[:yacht][:engine_commins])
    render :partial=>'/yachts/showspecification'
  end
  
  def editbrokercomment
    @yacht = Yacht.find_by_id(params[:id])
    render :update do |page|
      page.replace_html 'div_brokercomment',:partial=>'/yachts/editbrokercomment'
    end
  end
  
  def updatebrokercomment
    @details = Yacht.find_by_id(params[:id])
    @details.update_attributes(:description=>params[:yacht][:description])
    render :partial=>'/yachts/showbrokercomment'
  end
  
  def editkeyfeatures
    @yacht = Yacht.find_by_id(params[:id])
    session[:yachtid]=@yacht.id
    @keysellingfeatures = Keysellingfeature.find(:all, :conditions => "broker_id = '#{session[:brokerid]}'", :order => :name)
    render :update do |page|
      page.replace_html 'div_keyfeatures',:partial=>'/yachts/editkeyfeatures'
    end
  end
  
  def updatekeyfeatures
    
    @keysellinglist = []
    @keysellinglistname = ''
      if params[:yacht]
        
        if not params[:key_selling_features].blank?
          (params[:key_selling_features].blank?)?(@keysellingfeatures = ''):(@keysellingfeatures = params[:key_selling_features])
          
          if not params[:key_selling_features].blank?
            @keysellinglist << add_features(@keysellingfeatures)
            @keysellinglistname += session[:featurename]
            session[:featurename]=nil
          end
        end
        if not params[:yacht][:key_selling_features].blank?
          (params[:yacht][:key_selling_features].blank?)?(@keysellingfeatures = ''):(@keysellingfeatures = params[:yacht][:key_selling_features])
          if not params[:yacht][:key_selling_features].blank?
            @keysellinglist << add_features(@keysellingfeatures)
            (@keysellinglistname.blank?)?(@keysellinglistname=session[:featurename]):(@keysellinglistname+=","+session[:featurename])
            session[:featurename]=nil
          end
        end
      end
   
	 @keysellinfeatures = Keysellingfeature.find(:all, :conditions => "broker_id = '#{session[:brokerid]}'", :order => :name)
    @yacht = Yacht.find(params[:id])
    if params[:yacht]
      if not @keysellinglist.blank?
        @yacht.keysellingfeatures.clear
        for feature_id in @keysellinglist
          @yacht.keysellingfeatures << Keysellingfeature.find(feature_id)
        end
        params[:yacht][:key_selling_features] = @keysellinglistname
      end
    end
    
    if @yacht.update_attributes(params[:yacht])
      #flash[:notice] = 'Yacht was successfully updated.'
      @details = @yacht 
      render :partial => '/yachts/showkeyfeatures'
    end
  end
  
  def editadditionaldetails
    @additionaldetail = Additionaldetail.find_by_id(params[:id])
    render :partial=>'/yachts/editadditionaldetails'
  end
  
  def updateadditionaldetails
    @additionaldetail = Additionaldetail.find_by_id(params[:id])
    @additionaldetail.update_attributes(:description=>params[:additionaldetail][:description])
    render :partial=>'/yachts/showadditionaldetails',:locals=>{:id=>@additionaldetail.id}
  end
  

  def removeimage
    @gallery = Gallery.find(params[:id])
    @gallery.destroy
    (params[:page].blank?)?(@page = 1):(@page=params[:page].to_i)
    @details = Yacht.find(session[:yachtid]) unless session[:yachtid].nil?
    render :partial => 'previewyachtgallery'
  end
end
