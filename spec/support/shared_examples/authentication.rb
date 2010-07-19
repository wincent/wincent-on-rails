shared_examples_for 'require_admin' do
  it 'stores the original URI in the session' do
    do_request
    session[:original_uri].should_not be_blank
    session[:original_uri].should == response.request.fullpath
  end

  it 'redirects to /login' do
    do_request
    response.should redirect_to('/login')
  end

  it 'shows a flash' do
    do_request
    cookie_flash['notice'].should =~ /requires administrator privileges/
  end
end

shared_examples_for 'require_admin (non-HTML)' do
  it 'returns status 403 (forbidden)' do
    do_request
    response.status.should == 403
  end

  it 'renders "forbidden" test' do
    do_request
    response.body.should match(/forbidden/i)
  end
end