class ArticlesController < ApplicationController
  before_filter :require_admin, :except => [:index, :show]

  def index
    @articles = Article.find(:all)
  end

  def new
    respond_to do |format|
      format.html {
        @article = Article.new(session[:new_article_params])
        session[:new_article_params] = nil
      }

      # this is the AJAX preview
      format.js {
        @preview = params[:body]
        render :partial => 'preview'
      }
    end
  end

  # NOTE: will need to sanitize titles here in some way
  # "foo € bar" is stored literally and the URL becomes "foo%20€%20bar"
  # (we want the € URL-encoded as well)
  def create
    @article = Article.new(params[:article])
    respond_to do |format|
      if @article.save
        flash[:notice] = 'Successfully created new article.'
        format.html { redirect_to wiki_path(@article) }
        #format.xml  { render :xml => @article, :status => :created, :location => @article }
      else
        flash[:error] = 'Failed to create new article.'
        format.html { render :action => 'new' }
        #format.xml  { render :xml => @article.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
    # NOTE: MySQL will do a case-insensitive find here, so "foo" and "FOO" refer to the same article
    @article = Article.find_by_title(params[:id]) || Article.find(params[:id])
    if @article.redirect.blank?
      render
    else
      # must decide what to do here
    end
  end

  def edit
    # must set up new revision here
  end

private

  def record_not_found
    if admin?
      flash[:notice] = 'Requested article not found: create it?'
      session[:new_article_params] = { :title => params[:id] }
      redirect_to new_wiki_path
    else
      # potentially offer a similar notice to the above and a login link here instead
      super wiki_index_path
    end
  end
end
