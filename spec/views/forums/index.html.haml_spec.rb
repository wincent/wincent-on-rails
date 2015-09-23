require 'spec_helper'

describe 'forums/index' do
  before do
    # use Forum.find_all here because it sets up "last_active_at" attributes for us
    3.times { Forum.make! }
    @forums = Forum.find_all
  end

  it 'has breadcrumbs' do
    mock(view).breadcrumbs.with_any_args
    render
  end
end
