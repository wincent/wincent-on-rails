class ArticlesController < ApplicationController
  before_filter :require_admin, :except => [ :index, :show ]
  before_filter :get_article, :only => [ :show, :edit, :update ]
  after_filter  :cache_index_feed, :only => :index
  cache_sweeper :article_sweeper, :only => [ :create, :update, :destroy ]

  def index
    respond_to do |format|
      format.html {
        @paginator  = Paginator.new(params, Article.count(:conditions => { :public => true }), wiki_index_path)
        @articles   = Article.find_recent @paginator
        @tags       = Article.top_tags # could fragment cache this to avoid the query
      }
      format.atom {
        @articles   = Article.find_recent_excluding_redirects
      }
    end
  end

  def new
    @article = Article.new(session[:new_article_params])
    session[:new_article_params] = nil
  end

  def create
    respond_to do |format|
      format.html {
        @article = Article.new(params[:article])
        if @article.save
          flash[:notice] = 'Successfully created new article.'
          redirect_to wiki_path(@article)
        else
          flash[:error] = 'Failed to create new article.'
          render :action => 'new'
        end
      }

      # this is the AJAX preview
      format.js {
        @preview = params[:body] || ''
        render :partial => 'preview'
      }
    end
  end

  def show
    # NOTE: MySQL will do a case-insensitive find here, so "foo" and "FOO" refer to the same article
    if @article.redirect?
      if session[:redirection_count] and session[:redirection_count] > 5
        clear_redirection_info
        flash[:error] = 'Too many redirections'
        redirect_to wiki_index_path
      else
        session[:redirection_count] = session[:redirection_count] ? session[:redirection_count] + 1 : 1
        session[:redirected_from] = params[:id]
        redirect_to url_or_path_for_redirect
      end
    else # not a redirect
      @redirected_from = Article.from_param(session[:redirected_from]) if session[:redirected_from]
      render
      clear_redirection_info
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
    @article = Article.from_param(params[:id]) || (raise ActiveRecord::RecordNotFound)
  end

  def cache_index_feed
    cache_page if params[:format] == 'atom'
  end

  def clear_redirection_info
    session[:redirected_from]   = nil
    session[:redirection_count] = 0
  end

  def record_not_found
    if admin?
      flash[:notice] = 'Requested article not found: create it?'
      session[:new_article_params] = { :title => Article.deparametrize(params[:id]).capitalize }
      redirect_to new_wiki_path
    else
      super wiki_index_path
    end
  end

  def url_or_path_for_redirect
    if @article.redirect =~ /\A\s*\[\[(.+)\]\]\s*\z/
      wiki_path $~[1].gsub(' ', '_')
    elsif @article.redirect =~ /\A\s*(http:\/\/.+)\s*\z/
      $~[1]
    else
      nil
    end
  end
end
