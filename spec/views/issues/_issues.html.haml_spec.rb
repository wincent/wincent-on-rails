require File.dirname(__FILE__) + '/../../spec_helper'

describe '/issues/_issues' do
  include IssuesHelper

  before do
    assigns[:issues] = [create_issue, create_issue, create_issue]
  end

  def do_render
    pending # url_for in lib/sortable.rb raises routing error
    # :controller => 'issues', :action => 'issues' (doesn't exist)
    # and suppresses :protocol => 'https'
    render :partial => '/issues/issues'
  end

  it 'should show pagination at top and bottom of the page' do
    do_render
    response.should have_tag('div.pagination', 2)
  end

  it 'should have a sortable header cell for the "kind" column'
  it 'should have a sortable header cell for the "id" column'
  it 'should have a sortable header cell for the "product" column'
  it 'should have a sortable header cell for the "summary" column'
  it 'should have a sortable header cell for the "status" column'
  it 'should have a sortable header cell for the "when" column'
  it 'should show the kind string for each issue'
  it 'should link to a kind-scoped search from the kind string'
  it 'should show the id number for each issue'
  it 'should show the product for each issue'
  it 'should link to a product-scoped search from the product string'
  it 'should show the summary for each issue'
  it 'should like to the issue "show" page from the summary text'
  it 'should show the status string for each issue'
  it 'should link to a status-scope search from the status string'
  it 'should show the timestamp information for each issue'
  it 'should employ alternating table rows'
end
