class ArticlesController < ApplicationController
  before_filter :require_admin, :except => [ :index, :show ]
  before_filter :get_article, :only => [ :show, :edit, :update ]
  def index
    @articles = Article.find(:all, :order => 'updated_at DESC', :limit => 20)
  end

  def new
    respond_to do |format|
      format.html {
        @article = Article.new(session[:new_article_params])
        session[:new_article_params] = nil
      }

      # this is the AJAX preview
      format.js {
        @preview = params[:body] || ''
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
    if @article.redirect.blank?
      @redirected_from = Article.find_by_title(session[:redirected_from]) || Article.find(session[:redirected_from]) rescue nil
      render
      clear_redirection_info
    else # this is a redirect
      if session[:redirection_count] and session[:redirection_count] > 5
        clear_redirection_info
        flash[:error] = 'Too many redirections'
        redirect_to wiki_index_path
      else
        session[:redirection_count] = session[:redirection_count] ? session[:redirection_count] + 1 : 1
        session[:redirected_from] = params[:id]
        redirect_to url_or_path_for_redirect
      end
    end
  end

  def edit
    render
  end

  def update
    if @article.update_attributes(params[:article])
      flash[:notice] = 'Successfully updated'
      redirect_to wiki_path(@article)
    else
      flash[:error] = 'Update failed'
      render :action => 'edit'
    end
  end

private

  def get_article
    @article = Article.find_by_title(params[:id]) || Article.find(params[:id])
  end

  def clear_redirection_info
    session[:redirected_from]   = nil
    session[:redirection_count] = 0
  end

  def record_not_found
    if admin?
      flash[:notice] = 'Requested article not found: create it?'
      session[:new_article_params] = { :title => params[:id] }
      redirect_to new_wiki_path
    else
      # potentially offer a similar notice to the above and a login link here instead
      # could also send an email to the administrator, although would have to turn that off if it lead to abuse
      super wiki_index_path
    end
  end

  def url_or_path_for_redirect
    if @article.redirect =~ /\A\s*\[\[(.+)\]\]\s*\z/
      wiki_path $~[1]
    elsif @article.redirect =~ /\A\s*(http:\/\/.+)\s*\z/
      $~[1]
    else
      nil
    end
  end
end
