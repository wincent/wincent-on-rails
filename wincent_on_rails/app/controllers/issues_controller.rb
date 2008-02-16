class IssuesController < ApplicationController
  acts_as_sortable  :by => [:id, :created_at, :updated_at], :default => :updated_at, :descending => true

  def index
    public_count  = Issue.count(:conditions => 'public = TRUE')
    if public_count > 0
      @paginator    = Paginator.new(params, public_count, issues_path)
      @issues       = Issue.find(:all, sort_options.merge({:offset => @paginator.offset, :limit => 10}))
    else
      @issues       = Issue.find(:all, sort_options.merge({:limit => 10}))
    end
  end
end
