class ReposController < ApplicationController
  before_filter :require_admin, :except => [:index, :show]

  def index
    render
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
end
