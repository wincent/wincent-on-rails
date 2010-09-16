class ReposController < ApplicationController
  # during initial testing, require admin for everything
  before_filter :require_admin#, :except => [:index, :show]
  before_filter :get_repo, :only => [:destroy, :edit, :show, :update]

  def index
    # for now only show public repos; may later want to add admin-only
    # viewing of private repos, but possibly under the admin namespace
    # to allow page-caching here
    @repos = Repo.published
  end

  def new
    @repo = Repo.new
  end

  def create
    @repo = Repo.new params[:repo]
    if @repo.save
      flash[:notice] = 'Successfully created new repo'
      redirect_to @repo
    else
      flash[:error] = 'Failed to create new repo'
      render :action => 'new'
    end
  end

  def show
    render
  end

  def edit
    raise "not yet imp"
  end

  def update
    raise "not yet imp"
  end

  def destroy
    raise "not yet imp"
  end

private

  def record_not_found
    super repos_path
  end

  def get_repo
    # TODO: let admin see private repos
    @repo = Repo.published.find_by_permalink! params[:id]
  end
end
