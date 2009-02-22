class ArticlesController < ApplicationController
  before_filter     :require_admin,   :except => [ :index, :show ]
  before_filter     :get_article,     :only => [ :show, :edit, :update ]
  caches_page       :index,           :if => Proc.new { |c| c.send(:is_atom?) }
  cache_sweeper     :article_sweeper, :only => [ :create, :update, :destroy ]

  def index
    respond_to do |format|
      format.html {
        # can't use page caching here because the view features relative dates
        # TODO: that's not true any more, now that we do relative dates via JS
        @paginator  = RestfulPaginator.new(params, Article.count(:conditions => { :public => true }), articles_url)
        @articles   = Article.find_recent @paginator
        @tags       = Article.find_top_tags
      }
      format.atom {
        @articles   = Article.find_recent_excluding_redirects
      }
    end
  end

  def new
    @article = Article.new session[:new_article_params]
    session[:new_article_params] = nil
  end

  def create
    respond_to do |format|
      format.html {
        @article = Article.new params[:article]
        if @article.save
          flash[:notice] = 'Successfully created new article.'
          redirect_to article_url(@article)
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
        redirect_to articles_url
      else
        if @article.wiki_redirect?
          session[:redirection_count] = session[:redirection_count] ? session[:redirection_count] + 1 : 1
          session[:redirected_from] = params[:id]
        end
        redirect_to url_for_redirect
      end
    else # not a redirect
      @redirected_from = Article.find_with_param!(session[:redirected_from]) if session[:redirected_from]
      render
      clear_redirection_info
    end
  end

  def edit
    render
  end

  def update
    if @article.update_attributes params[:article]
      flash[:notice] = 'Successfully updated'
      redirect_to article_url(@article)
    else
      flash[:error] = 'Update failed'
      render :action => 'edit'
    end
  end

private

  def get_article
    @article = Article.find_with_param! params[:id]
  end

  def record_not_found
    if admin?
      flash[:notice] = 'Requested article not found: create it?'
      session[:new_article_params] = { :title => Article.deparametrize(params[:id]).capitalize }
      redirect_to new_article_url
    else
      super articles_url
    end
  end

  def url_for_redirect
    if @article.redirect =~ /\A\s*\[\[(.+)\]\]\s*\z/
      article_url Article.parametrize($~[1])
    elsif @article.redirect =~ /\A\s*((https?:\/\/.+)|(\/.+))\s*\z/
      $~[1]
    else
      nil
    end
  end

  def clear_redirection_info
    session[:redirected_from]   = nil
    session[:redirection_count] = 0
  end
end
