require File.dirname(__FILE__) + '/watirspec/spec_helper'

describe "Browser" do
  describe "#new" do
    it "raises TypeError if argument is not a Hash" do
      lambda { Browser.new(:foo) }.should raise_error(TypeError)
    end

    it "raises ArgumentError if given bad arguments for :render key" do
      lambda { Browser.new(:render => :foo) }.should raise_error(ArgumentError)
    end

    it "raises ArgumentError if given bad arguments for :browser key" do
      lambda { Browser.new(:browser => 'foo') }.should raise_error(ArgumentError)
    end

    it "raises ArgumentError if given an unknown option" do
      lambda { Browser.new(:foo => 1) }.should raise_error(ArgumentError)
    end

    it "should hold the init options" do
      browser.options.should == WatirSpec.browser_args.first
    end

    it "should use the specified proxy" do
      # TODO: find a better way to test this with rack
      require 'webrick/httpproxy'

      received = false
      blk      = lambda { received = true }
      s = WEBrick::HTTPProxyServer.new(:Port => 2001, :ProxyContentHandler => blk)
      Thread.new { s.start }

      b = Browser.new(WatirSpec.browser_args.first.merge(:proxy => "localhost:2001"))
      b.goto(WatirSpec.host)
      s.shutdown

      received.should be_true
    end

    it "should use the specified user agent" do
      b = Browser.new(WatirSpec.browser_args.first.merge(:user_agent => "Celerity"))
      b.goto(WatirSpec.host + "/header_echo")
      b.text.should include('"HTTP_USER_AGENT"=>"Celerity"')
      b.close
    end

    it "does not try to find a viewer if created with :viewer => false" do
      ViewerConnection.should_not_receive(:create)

      b = Browser.new(:viewer => false)
      b.close
    end

    it "tries to find a viewer if created with :viewer => nil" do
      ViewerConnection.should_receive(:create).with("127.0.0.1", 6429)

      b = Browser.new(:viewer => nil)
      b.close
    end

    it "tries to find a viewer on the specified host/port with :viewer => String" do
      ViewerConnection.should_receive(:create).with("localhost", 1234)

      b = Browser.new(:viewer => "localhost:1234")
      b.close
    end
  end

  describe "#html" do
    %w(shift_jis iso-2022-jp euc-jp).each do |charset|
      it "returns decoded #{charset.upcase} when :charset specified" do
        browser = Browser.new(WatirSpec.browser_args.first.merge(:charset => charset.upcase))
        browser.goto(WatirSpec.files + "/#{charset}_text.html")
        # Browser#text is automagically transcoded into the right charset, but Browser#html isn't.
        browser.html.should =~ /本日は晴天なり。/
        browser.close
      end
    end
  end

  describe "#response_headers" do
    it "returns the response headers (as a hash)" do
      browser.goto(WatirSpec.host + "/non_control_elements.html")
      browser.response_headers.should be_kind_of(Hash)
      browser.response_headers['Date'].should be_kind_of(String)
      browser.response_headers['Content-Type'].should be_kind_of(String)
    end
  end

  describe "#content_type" do
    it "returns the content type" do
      browser.goto(WatirSpec.host + "/non_control_elements.html")
      browser.content_type.should =~ /\w+\/\w+/
    end
  end

  describe "#io" do
    it "returns the io object of the content" do
      browser.goto(WatirSpec.files + "/non_control_elements.html")
      browser.io.should be_kind_of(IO)
      browser.io.read.should == File.read("#{WatirSpec.html}/non_control_elements.html")
    end
  end

  describe "#goto" do
    it "raises UnexpectedPageException if the content type is not understood" do
      lambda { browser.goto(WatirSpec.host + "/octet_stream") }.should raise_error(UnexpectedPageException)
    end
  end

  describe "#cookies" do
    it "returns set cookies as a Ruby hash" do
      cookies = browser.cookies
      cookies.should be_instance_of(Hash)
      cookies.should be_empty

      browser.goto(WatirSpec.host + "/set_cookie")

      cookies = browser.cookies
      cookies.size.should == 1
      cookies[WatirSpec::Server.host]['monster'].should == "/"
    end
  end

  describe "#clear_cookies" do
    it "clears all cookies" do
      b = WatirSpec.new_browser
      b.cookies.should be_empty

      b.goto(WatirSpec.host + "/set_cookie")
      b.cookies.size.should == 1
      b.clear_cookies
      b.cookies.should be_empty

      b.close
    end
  end

  describe "add_cookie" do
    it "adds a cookie with the given domain, name and value" do
      browser.add_cookie("example.com", "foo", "bar")
      cookies = browser.cookies
      cookies.should be_instance_of(Hash)
      cookies.should have_key('example.com')
      cookies['example.com']['foo'].should == 'bar'

      browser.clear_cookies
    end

    it "adds a cookie with the specified options" do
      browser.add_cookie("example.com", "foo", "bar", :path => "/foobar", :max_age => 1000)
      cookies = browser.cookies
      cookies.should be_instance_of(Hash)
      cookies['example.com']['foo'].should == 'bar'
    end
  end

  describe "remove_cookie" do
    it "removes the cookie for the given domain and name" do
      b = WatirSpec.new_browser
      b.goto(WatirSpec.host + "/set_cookie")

      b.remove_cookie(WatirSpec::Server.host, "monster")
      b.cookies.should be_empty

      b.close
    end

    it "raises an error if no such cookie exists" do
      lambda { browser.remove_cookie("bogus.com", "bar") }.should raise_error(CookieNotFoundError)
    end
  end

  describe "#wait" do
    it "should wait for javascript timers to finish" do
      alerts = 0
      browser.add_listener(:alert) { alerts += 1 }
      browser.goto(WatirSpec.files + "/timeout.html")
      browser.div(:id, 'alert').click
      browser.wait.should be_true
      alerts.should == 1
    end
  end

  describe "#wait_while" do
    it "waits until the specified condition becomes false" do
      browser.goto(WatirSpec.files + "/timeout.html")
      browser.div(:id, "change").click
      browser.wait_while { browser.contains_text("Trigger change") }
      browser.div(:id, "change").text.should == "all done"
    end

    it "returns the value returned from the block" do
      browser.wait_while { false }.should == false
    end
  end

  describe "#wait_until" do
    it "waits until the condition becomes true" do
      browser.goto(WatirSpec.files + "/timeout.html")
      browser.div(:id, "change").click
      browser.wait_until { browser.contains_text("all done") }
    end

    it "returns the value returned from the block" do
      browser.wait_until { true }.should == true
    end
  end

  describe "#element_by_xpath" do
    it "returns usable elements even though they're not supported" do
      browser.goto(WatirSpec.files + "/forms_with_input_elements.html")

      el = browser.element_by_xpath("//link")
      el.should be_instance_of(Celerity::Element)
      el.rel.should == "stylesheet"
    end
  end

  describe "#focused_element" do
    it "returns the element that currently has the focus" do
      b = WatirSpec.new_browser
      b.goto(WatirSpec.files + "/forms_with_input_elements.html")
      b.focused_element.id.should == "new_user_first_name"

      b.close
    end
  end

  describe "#status_code" do
    it "returns the status code of the last request" do
      browser.goto(WatirSpec.files + "/forms_with_input_elements.html")
      browser.status_code.should == 200

      browser.goto(WatirSpec.host + "/doesnt_exist")
      browser.status_code.should == 404
    end
  end

  describe "#status_code_exceptions" do
    it "raises status code exceptions if set to true" do
      browser.status_code_exceptions = true
      lambda do
        browser.goto(WatirSpec.host + "/doesnt_exist")
      end.should raise_error(NavigationException)
    end
  end

  describe "#javascript_exceptions" do
    it "raises javascript exceptions if set to true" do
      browser.goto(WatirSpec.files + "/forms_with_input_elements.html")
      browser.javascript_exceptions = true
      lambda do
        browser.execute_script("no_such_function()")
      end.should raise_error
    end
  end

  describe "#add_listener" do
    it "should click OK for confirm() calls" do
      browser.goto(WatirSpec.files + "/forms_with_input_elements.html")
      browser.add_listener(:confirm) {  }
      browser.execute_script("confirm()").should == true
    end
  end

  describe "#add_checker" do

    # watir only supports a lambda instance as argument, celerity supports both
    it "runs the given block on each page load" do
      output = ''

      browser.add_checker { |browser| output << browser.text }
      browser.goto(WatirSpec.files + "/non_control_elements.html")

      output.should include('Dubito, ergo cogito, ergo sum')
    end
  end


  describe "#confirm" do
    it "clicks 'OK' for a confirm() call" do
      browser.goto(WatirSpec.files + "/forms_with_input_elements.html")

      browser.confirm(true) do
        browser.execute_script('confirm()').should be_true
      end
    end

    it "clicks 'cancel' for a confirm() call" do
      browser.goto(WatirSpec.files + "/forms_with_input_elements.html")

      browser.confirm(false) do
        browser.execute_script('confirm()').should be_false
      end
    end
  end

end
