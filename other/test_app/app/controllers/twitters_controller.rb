class TwittersController < ApplicationController
  # GET /twitters
  # GET /twitters.xml
  def index
    @twitters = Twitter.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @twitters }
    end
  end

  # GET /twitters/1
  # GET /twitters/1.xml
  def show
    @twitter = Twitter.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @twitter }
    end
  end

  # GET /twitters/new
  # GET /twitters/new.xml
  def new
    @twitter = Twitter.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @twitter }
    end
  end

  # GET /twitters/1/edit
  def edit
    @twitter = Twitter.find(params[:id])
  end

  # POST /twitters
  # POST /twitters.xml
  def create
    @twitter = Twitter.new(params[:twitter])

    respond_to do |format|
      if @twitter.save
        flash[:notice] = 'Twitter was successfully created.'
        format.html { redirect_to(@twitter) }
        format.xml  { render :xml => @twitter, :status => :created, :location => @twitter }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @twitter.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /twitters/1
  # PUT /twitters/1.xml
  def update
    @twitter = Twitter.find(params[:id])

    respond_to do |format|
      if @twitter.update_attributes(params[:twitter])
        flash[:notice] = 'Twitter was successfully updated.'
        format.html { redirect_to(@twitter) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @twitter.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /twitters/1
  # DELETE /twitters/1.xml
  def destroy
    @twitter = Twitter.find(params[:id])
    @twitter.destroy

    respond_to do |format|
      format.html { redirect_to(twitters_url) }
      format.xml  { head :ok }
    end
  end
end
