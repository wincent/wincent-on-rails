class SupportController < ApplicationController
  acts_as_sortable  :by => [:kind, :id, :product_id, :summary, :updated_at], :default => :updated_at, :descending => true

  def index
    @paginator    = Paginator.new(params, Issue.count(:conditions => { :public => true }), issues_path)
    @issues       = Issue.find :all, sort_options.merge({:offset => @paginator.offset, :limit => @paginator.limit})
  end
end
