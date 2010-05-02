class ArticlesController < ApplicationController
  before_filter     :require_admin,   :except => [ :index, :show ]
  before_filter     :get_article,     :only => [ :show, :edit, :update ]
  caches_page       :index, :show,    :if => Proc.new { |c| c.send(:is_atom?) }
  cache_sweeper     :article_sweeper, :only => [ :create, :update, :destroy ]

  def index
    respond_to do |format|
      format.html {
        @paginator  = RestfulPaginator.new params,
          Article.count(:conditions => { :public => true }), articles_path
        @articles   = Article.find_recent :offset => @paginator.offset
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
    if request.xhr? # live preview
      @article = Article.new :title => params[:title], :body => params[:body]
      render :partial => 'preview'
    else # normal request
      @article = Article.new params[:article]
      if @article.save
        flash[:notice] = 'Successfully created new article'
        redirect_to @article
      else
        flash[:error] = 'Failed to create new article'
        render :action => 'new'
      end
    end
  end

  def show
    # NOTE: MySQL will do a case-insensitive find here, so "foo" and "FOO" refer to the same article
    if @article.redirect?
      if session[:redirection_count] and session[:redirection_count] > 5
        clear_redirection_info
        flash[:error] = 'Too many redirections'
        redirect_to articles_path
      else
        if @article.wiki_redirect?
          session[:redirection_count] = session[:redirection_count] ? session[:redirection_count] + 1 : 1
          session[:redirected_from] = params[:id]
        end
        redirect_to url_for_redirect
      end
    else # not a redirect
      @redirected_from = Article.find_with_param!(session[:redirected_from]) if session[:redirected_from]
      @comments = @article.comments.published
      respond_to do |format|
        format.html {
          flash[:notice] = stale_article_notice if @article.updated_at < 1.year.ago
          @comment = @article.comments.build if @article.accepts_comments?
        }
        format.atom
      end
      clear_redirection_info
    end
  end

  def edit
    render
  end

  def update
    if @article.update_attributes params[:article]
      flash[:notice] = 'Successfully updated'
      redirect_to @article
    else
      flash[:error] = 'Update failed'
      render :action => 'edit'
    end
  end

private

  def stale_article_notice
    <<-NOTICE
      This article is over 1 year old <em>(to check for a more recent resource
      see the <a href="#{articles_path}">wiki</a> index, the
      <a href="#{tags_path}">tag cloud</a>, the
      <a href="#{search_tags_path}">tag search</a>,
      or the <a href="#{new_search_path}">search</a> page)</em>
    NOTICE
  end

  def get_article
    # BUG: public/private distinction is ignored here
    @article = Article.find_with_param! params[:id]
  rescue ActiveRecord::RecordNotFound => e
    # given title "Foo" a request for "Foo.atom" will most likely wind up here
    if params[:id] =~ /(.+)\.atom\Z/
      params[:format] = 'atom'
      @article = Article.find_with_param! $~[1]
    end
    raise e unless @article
  end

  def record_not_found
    if admin?
      flash[:notice] = 'Requested article not found: create it?'
      title = Article.deparametrize(params[:id])
      session[:new_article_params] = { :title => Article.smart_capitalize(title) }
      redirect_to new_article_path
    else
      super articles_path
    end
  end

  def url_for_redirect
    if @article.redirect =~ /\A\s*\[\[(.+)\]\]\s*\z/
      article_path Article.parametrize($~[1])
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
