class SupportController < ApplicationController
  acts_as_sortable  :by => [:public, :kind, :id, :product_id, :summary, :status, :updated_at],
                    :default => :updated_at,
                    :descending => true

  def index
    options     = default_access_options # defined in ApplicationController
    @paginator  = Paginator.new params, Issue.count(:conditions => options), issues_url
    @issues     = Issue.find :all,
      sort_options.merge({:offset => @paginator.offset, :limit => @paginator.limit, :conditions => options})
  end
end
