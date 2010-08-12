class ReposController < ApplicationController
  before_filter :require_admin, :except => [:index, :show]

  def index
    render
  end

  def new
    @repo = Repo.new
  end
end
