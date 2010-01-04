require File.expand_path('spec_helper', File.dirname(__FILE__))

require 'nokogiri'

shared_examples_for "session" do
  def extract_results(session)
    YAML.load Nokogiri::HTML(session.body).xpath("//pre[@id='results']").first.text
  end

  describe '#app' do
    it "should remember the application" do
      @session.app.should == TestApp
    end
  end

  describe '#visit' do
    it "should fetch a response from the driver" do
      @session.visit('/')
      @session.body.should include('Hello world!')
      @session.visit('/foo')
      @session.body.should include('Another World')
    end
  end
  
  describe '#click' do
    it "should click on a link" do
      @session.visit('/with_html')
      @session.click('labore')
      @session.body.should include('<h1>Bar</h1>')
    end
    
    it "should click on a button" do
      @session.visit('/form')
      @session.click('awe123')
      extract_results(@session)['first_name'].should == 'John'
    end
    
    context "with a locator that doesn't exist" do
      it "should raise an error" do
        @session.visit('/with_html')
        running do
          @session.click('does not exist')
        end.should raise_error(Capybara::ElementNotFound)
      end
    end
  end

  describe '#click_link' do
    before do
      @session.visit('/with_html')
    end

    context "with id given" do
      it "should take user to the linked page" do
        @session.click_link('foo')
        @session.body.should include('Another World')
      end
    end

    context "with text given" do
      it "should take user to the linked page" do
        @session.click_link('labore')
        @session.body.should include('<h1>Bar</h1>')
      end
    end

    context "with title given" do
      it "should take user to the linked page" do
        @session.click_link('awesome title')
        @session.body.should include('<h1>Bar</h1>')
      end
    end

    context "with a locator that doesn't exist" do
      it "should raise an error" do
        running do
          @session.click_link('does not exist')
        end.should raise_error(Capybara::ElementNotFound)
      end
    end

    it "should follow redirects" do
      @session.click_link('Redirect')
      @session.body.should include('You landed')
    end
  end

  describe '#click_button' do
    before do
      @session.visit('/form')
    end

    context "with multiple values with the same name" do
      it "should use the latest given value" do
        @session.check('Terms of Use')
        @session.click_button('awesome')
        extract_results(@session)['terms_of_use'].should == '1'
      end
    end

    context "with value given on a submit button" do
      before do
        @session.click_button('awesome')
        @results = extract_results(@session)
      end

      it "should serialize and submit text fields" do
        @results['first_name'].should == 'John'
      end

      it "should escape fields when submitting" do
        @results['phone'].should == '+1 555 7021'
      end

      it "should serialize and submit password fields" do
        @results['password'].should == 'seeekrit'
      end

      it "should serialize and submit hidden fields" do
        @results['token'].should == '12345'
      end

      it "should not serialize fields from other forms" do
        @results['middle_name'].should be_nil
      end

      it "should submit the button that was clicked, but not other buttons" do
        @results['awesome'].should == 'awesome'
        @results['crappy'].should be_nil
      end

      it "should serialize radio buttons" do
        @results['gender'].should == 'female'
      end

      it "should serialize check boxes" do
        @results['pets'].should include('dog', 'hamster')
        @results['pets'].should_not include('cat')
      end

      it "should serialize text areas" do
        @results['description'].should == 'Descriptive text goes here'
      end

      it "should serialize select tag with values" do
        @results['locale'].should == 'en'
      end

      it "should serialize select tag without values" do
        @results['region'].should == 'Norway'
      end

      it "should serialize first option for select tag with no selection" do
        @results['city'].should == 'London'
      end

      it "should not serialize a select tag without options" do
        @results['tendency'].should be_nil
      end
    end

    context "with id given on a submit button" do
      it "should submit the associated form" do
        @session.click_button('awe123')
        extract_results(@session)['first_name'].should == 'John'
      end
    end

    context "with value given on an image button" do
      it "should submit the associated form" do
        @session.click_button('okay')
        extract_results(@session)['first_name'].should == 'John'
      end
    end

    context "with id given on an image button" do
      it "should submit the associated form" do
        @session.click_button('okay556')
        extract_results(@session)['first_name'].should == 'John'
      end
    end

    context "with text given on a button defined by <button> tag" do
      it "should submit the associated form" do
        @session.click_button('Click me')
        extract_results(@session)['first_name'].should == 'John'
      end
    end

   context "with id given on a button defined by <button> tag" do
      it "should submit the associated form" do
        @session.click_button('click_me_123')
        extract_results(@session)['first_name'].should == 'John'
      end
    end

   context "with value given on a button defined by <button> tag" do
      it "should submit the associated form" do
        @session.click_button('click_me')
        extract_results(@session)['first_name'].should == 'John'
      end
    end

    context "with a locator that doesn't exist" do
      it "should raise an error" do
        running do
          @session.click_button('does not exist')
        end.should raise_error(Capybara::ElementNotFound)
      end
    end

    it "should serialize and send GET forms" do
      @session.visit('/form')
      @session.click_button('med')
      @results = extract_results(@session)
      @results['middle_name'].should == 'Darren'
      @results['foo'].should be_nil
    end

    it "should follow redirects" do
      @session.click_button('Go FAR')
      @session.body.should include('You landed')
    end
  end

  describe "#fill_in" do
    before do
      @session.visit('/form')
    end

    it "should fill in a text field by id" do
      @session.fill_in('form_first_name', :with => 'Harry')
      @session.click_button('awesome')
      extract_results(@session)['first_name'].should == 'Harry'
    end

    it "should fill in a text field by label" do
      @session.fill_in('First Name', :with => 'Harry')
      @session.click_button('awesome')
      extract_results(@session)['first_name'].should == 'Harry'
    end

    it "should favour exact label matches over partial matches" do
      @session.fill_in('Name', :with => 'Harry Jones')
      @session.click_button('awesome')
      extract_results(@session)['name'].should == 'Harry Jones'
    end

    it "should fill in a textarea by id" do
      @session.fill_in('form_description', :with => 'Texty text')
      @session.click_button('awesome')
      extract_results(@session)['description'].should == 'Texty text'
    end

    it "should fill in a textarea by label" do
      @session.fill_in('Description', :with => 'Texty text')
      @session.click_button('awesome')
      extract_results(@session)['description'].should == 'Texty text'
    end

    it "should fill in a password field by id" do
      @session.fill_in('form_password', :with => 'supasikrit')
      @session.click_button('awesome')
      extract_results(@session)['password'].should == 'supasikrit'
    end

    it "should fill in a password field by label" do
      @session.fill_in('Password', :with => 'supasikrit')
      @session.click_button('awesome')
      extract_results(@session)['password'].should == 'supasikrit'
    end

    context "with a locator that doesn't exist" do
      it "should raise an error" do
        running do
          @session.fill_in('does not exist', :with => 'Blah blah')
        end.should raise_error(Capybara::ElementNotFound)
      end
    end
  end

  describe "#choose" do
    before do
      @session.visit('/form')
    end

    it "should choose a radio button by id" do
      @session.choose("gender_male")
      @session.click_button('awesome')
      extract_results(@session)['gender'].should == 'male'
    end

    it "should choose a radio button by label" do
      @session.choose("Both")
      @session.click_button('awesome')
      extract_results(@session)['gender'].should == 'both'
    end

    context "with a locator that doesn't exist" do
      it "should raise an error" do
        running { @session.choose('does not exist') }.should raise_error(Capybara::ElementNotFound)
      end
    end
  end

  describe "#check" do
    before do
      @session.visit('/form')
    end

    it "should check a checkbox by id" do
      @session.check("form_pets_cat")
      @session.click_button('awesome')
      extract_results(@session)['pets'].should include('dog', 'cat', 'hamster')
    end

    it "should check a checkbox by label" do
      @session.check("Cat")
      @session.click_button('awesome')
      extract_results(@session)['pets'].should include('dog', 'cat', 'hamster')
    end

    context "with a locator that doesn't exist" do
      it "should raise an error" do
        running { @session.check('does not exist') }.should raise_error(Capybara::ElementNotFound)
      end
    end
  end

  describe "#uncheck" do
    before do
      @session.visit('/form')
    end

    it "should uncheck a checkbox by id" do
      @session.uncheck("form_pets_hamster")
      @session.click_button('awesome')
      extract_results(@session)['pets'].should include('dog')
      extract_results(@session)['pets'].should_not include('hamster')
    end

    it "should uncheck a checkbox by label" do
      @session.uncheck("Hamster")
      @session.click_button('awesome')
      extract_results(@session)['pets'].should include('dog')
      extract_results(@session)['pets'].should_not include('hamster')
    end

    context "with a locator that doesn't exist" do
      it "should raise an error" do
        running { @session.uncheck('does not exist') }.should raise_error(Capybara::ElementNotFound)
      end
    end
  end

  describe "#select" do
    before do
      @session.visit('/form')
    end

    it "should select an option from a select box by id" do
      @session.select("Finish", :from => 'form_locale')
      @session.click_button('awesome')
      extract_results(@session)['locale'].should == 'fi'
    end

    it "should select an option from a select box by label" do
      @session.select("Finish", :from => 'Locale')
      @session.click_button('awesome')
      extract_results(@session)['locale'].should == 'fi'
    end

    context "with a locator that doesn't exist" do
      it "should raise an error" do
        running { @session.select('foo', :from => 'does not exist') }.should raise_error(Capybara::ElementNotFound)
      end
    end
  end

  describe '#has_content?' do
    it "should be true if the given content is on the page at least once" do
      @session.visit('/with_html')
      @session.should have_content('est')
      @session.should have_content('Lorem')
      @session.should have_content('Redirect')
    end

    it "should be true if scoped to an element which has the content" do
      @session.visit('/with_html')
      @session.within("//a[@title='awesome title']") do
        @session.should have_content('labore')
      end
    end

    it "should be false if the given content is not on the page" do
      @session.visit('/with_html')
      @session.should_not have_content('xxxxyzzz')
      @session.should_not have_content('monkey')
    end

    it 'should handle single quotes in the content' do
      @session.visit('/with-quotes')
      @session.should have_content("can't")
    end

    it 'should handle double quotes in the content' do
      @session.visit('/with-quotes')
      @session.should have_content(%q{"No," he said})
    end

    it 'should handle mixed single and double quotes in the content' do
      @session.visit('/with-quotes')
      @session.should have_content(%q{"you can't do that."})
    end
  end

  describe '#has_xpath?' do
    before do
      @session.visit('/with_html')
    end

    it "should be true if the given selector is on the page" do
      @session.should have_xpath("//p")
      @session.should have_xpath("//p//a[@id='foo']")
      @session.should have_xpath("//p[contains(.,'est')]")
    end

    it "should be false if the given selector is not on the page" do
      @session.should_not have_xpath("//abbr")
      @session.should_not have_xpath("//p//a[@id='doesnotexist']")
      @session.should_not have_xpath("//p[contains(.,'thisstringisnotonpage')]")
    end

    it "should respect scopes" do
      @session.within "//p[@id='first']" do
        @session.should have_xpath("//a[@id='foo']")
        @session.should_not have_xpath("//a[@id='red']")
      end
    end

    context "with count" do
      it "should be true if the content is on the page the given number of times" do
        @session.should have_xpath("//p", :count => 3)
        @session.should have_xpath("//p//a[@id='foo']", :count => 1)
        @session.should have_xpath("//p[contains(.,'est')]", :count => 1)
      end

      it "should be false if the content is on the page the given number of times" do
        @session.should_not have_xpath("//p", :count => 6)
        @session.should_not have_xpath("//p//a[@id='foo']", :count => 2)
        @session.should_not have_xpath("//p[contains(.,'est')]", :count => 5)
      end

      it "should be false if the content isn't on the page at all" do
        @session.should_not have_xpath("//abbr", :count => 2)
        @session.should_not have_xpath("//p//a[@id='doesnotexist']", :count => 1)
      end
    end

    context "with text" do
      it "should discard all matches where the given string is not contained" do
        @session.should have_xpath("//p//a", :text => "Redirect", :count => 1)
        @session.should_not have_xpath("//p", :text => "Doesnotexist")
      end

      it "should discard all matches where the given regexp is not matched" do
        @session.should have_xpath("//p//a", :text => /re[dab]i/i, :count => 1)
        @session.should_not have_xpath("//p//a", :text => /Red$/)
      end
    end
  end

  describe '#has_css?' do
    before do
      @session.visit('/with_html')
    end

    it "should be true if the given selector is on the page" do
      @session.should have_css("p")
      @session.should have_css("p a#foo")
    end

    it "should be false if the given selector is not on the page" do
      @session.should_not have_css("abbr")
      @session.should_not have_css("p a#doesnotexist")
      @session.should_not have_css("p.nosuchclass")
    end

    it "should respect scopes" do
      @session.within "//p[@id='first']" do
        @session.should have_css("a#foo")
        @session.should_not have_css("a#red")
      end
    end

    context "with count" do
      it "should be true if the content is on the page the given number of times" do
        @session.should have_css("p", :count => 3)
        @session.should have_css("p a#foo", :count => 1)
      end

      it "should be false if the content is on the page the given number of times" do
        @session.should_not have_css("p", :count => 6)
        @session.should_not have_css("p a#foo", :count => 2)
      end

      it "should be false if the content isn't on the page at all" do
        @session.should_not have_css("abbr", :count => 2)
        @session.should_not have_css("p a.doesnotexist", :count => 1)
      end
    end

    context "with text" do
      it "should discard all matches where the given string is not contained" do
        @session.should have_css("p a", :text => "Redirect", :count => 1)
        @session.should_not have_css("p a", :text => "Doesnotexist")
      end

      it "should discard all matches where the given regexp is not matched" do
        @session.should have_css("p a", :text => /re[dab]i/i, :count => 1)
        @session.should_not have_css("p a", :text => /Red$/)
      end
    end
  end

  describe "#attach_file" do
    before do
      @session.visit('/form')
    end

    context "with normal form" do
      it "should set a file path by id" do
        @session.attach_file "form_image", __FILE__
        @session.click_button('awesome')
        extract_results(@session)['image'].should == File.basename(__FILE__)
      end

      it "should set a file path by label" do
        @session.attach_file "Image", __FILE__
        @session.click_button('awesome')
        extract_results(@session)['image'].should == File.basename(__FILE__)
      end
    end

    context "with multipart form" do
      before do
        @test_file_path = File.expand_path('fixtures/test_file.txt', File.dirname(__FILE__))
      end

      it "should set a file path by id" do
        @session.attach_file "form_document", @test_file_path
        @session.click_button('Upload')
        @session.body.should include(File.read(@test_file_path))
      end

      it "should set a file path by label" do
        @session.attach_file "Document", @test_file_path
        @session.click_button('Upload')
        @session.body.should include(File.read(@test_file_path))
      end

      it "should not break if no file is submitted" do
        @session.click_button('Upload')
        @session.body.should include('No file uploaded')
      end
    end

    context "with a locator that doesn't exist" do
      it "should raise an error" do
        running { @session.attach_file('does not exist', 'foo.txt') }.should raise_error(Capybara::ElementNotFound)
      end
    end
  end

  describe '#find_field' do
    before do
      @session.visit('/form')
    end

    it "should find any field" do
      @session.find_field('Dog').value.should == 'dog'
      @session.find_field('form_description').text.should == 'Descriptive text goes here'
      @session.find_field('Region')[:name].should == 'form[region]'
    end

    it "should be nil if the field doesn't exist" do
      @session.find_field('Does not exist').should be_nil
    end

    it "should be aliased as 'field_labeled' for webrat compatibility" do
      @session.field_labeled('Dog').value.should == 'dog'
      @session.field_labeled('Does not exist').should be_nil
    end
  end

  describe '#find_link' do
    before do
      @session.visit('/with_html')
    end

    it "should find any field" do
      @session.find_link('foo').text.should == "ullamco"
      @session.find_link('labore')[:href].should == "/with_simple_html"
    end

    it "should return nil if the field doesn't exist" do
      @session.find_link('Does not exist').should be_nil
    end
  end

  describe '#find_button' do
    before do
      @session.visit('/form')
    end

    it "should find any field" do
      @session.find_button('med')[:id].should == "mediocre"
      @session.find_button('crap321').value.should == "crappy"
    end

    it "should return nil if the field doesn't exist" do
      @session.find_button('Does not exist').should be_nil
    end
  end

  describe '#all' do
    before do
      @session.visit('/with_html')
    end

    it "should find all elements using the given locator" do
      @session.all('//p').should have(3).elements
      @session.all('//h1').first.text.should == 'This is a test'
      @session.all("//input[@id='test_field']").first[:value].should == 'monkey'
    end

    it "should return an empty array when nothing was found" do
      @session.all('//div').should be_empty
    end

    it "should accept an XPath instance" do
      @session.visit('/form')
      @xpath = Capybara::XPath.text_field('Name')
      @result = @session.all(@xpath)
      @result.map(&:value).should include('Smith', 'John', 'John Smith')
    end

    context "within a scope" do
      before do
        @session.visit('/with_scope')
      end

      it "should find any element using the given locator" do
        @session.within(:xpath, "//div[@id='for_bar']") do
          @session.all('//li').should have(2).elements
        end
      end
    end
  end

  describe '#find' do
    before do
      @session.visit('/with_html')
    end

    it "should find the first element using the given locator" do
      @session.find('//h1').text.should == 'This is a test'
      @session.find("//input[@id='test_field']")[:value].should == 'monkey'
    end

    it "should return nil when nothing was found" do
      @session.find('//div').should be_nil
    end

    it "should accept an XPath instance and respect the order of paths" do
      @session.visit('/form')
      @xpath = Capybara::XPath.text_field('Name')
      @session.find(@xpath).value.should == 'John Smith'
    end

    context "within a scope" do
      before do
        @session.visit('/with_scope')
      end

      it "should find the first element using the given locator" do
        @session.within(:xpath, "//div[@id='for_bar']") do
          @session.find('//li').text.should =~ /With Simple HTML/
        end
      end
    end
  end
  
  describe '#wait_for' do
    before do
      @session.visit('/with_html')
    end

    it "should find the first element using the given locator" do
      @session.wait_for('//h1').text.should == 'This is a test'
      @session.wait_for("//input[@id='test_field']")[:value].should == 'monkey'
    end
    
    it "should return nil when nothing was found" do
      @session.wait_for('//div').should be_nil
    end
    
    it "should accept an XPath instance and respect the order of paths" do
      @session.visit('/form')
      @xpath = Capybara::XPath.text_field('Name')
      @session.wait_for(@xpath).value.should == 'John Smith'
    end
    
    context "within a scope" do
      before do
        @session.visit('/with_scope')
      end

      it "should find the first element using the given locator" do
        @session.within(:xpath, "//div[@id='for_bar']") do
          @session.wait_for('//li').text.should =~ /With Simple HTML/
        end        
      end
    end
  end

  describe '#within' do
    before do
      @session.visit('/with_scope')
    end

    context "with CSS selector" do
      it "should click links in the given scope" do
        @session.within(:css, "ul li[contains('With Simple HTML')]") do
          @session.click_link('Go')
        end
        @session.body.should include('<h1>Bar</h1>')
      end
    end

    context "with XPath selector" do
      it "should click links in the given scope" do
        @session.within(:xpath, "//li[contains(.,'With Simple HTML')]") do
          @session.click_link('Go')
        end
        @session.body.should include('<h1>Bar</h1>')
      end
    end

    context "with the default selector" do
      it "should use XPath" do
        @session.within("//li[contains(., 'With Simple HTML')]") do
          @session.click_link('Go')
        end
        @session.body.should include('<h1>Bar</h1>')
      end
    end

    context "with the default selector set to CSS" do
      after do
        Capybara.default_selector = :xpath
      end

      it "should use CSS" do
        Capybara.default_selector = :css
        @session.within("ul li[contains('With Simple HTML')]") do
          @session.click_link('Go')
        end
        @session.body.should include('<h1>Bar</h1>')
      end
    end

    context "with click_link" do
      it "should click links in the given scope" do
        @session.within("//li[contains(.,'With Simple HTML')]") do
          @session.click_link('Go')
        end
        @session.body.should include('<h1>Bar</h1>')
      end

      context "with nested scopes" do
        it "should respect the inner scope" do
          @session.within("//div[@id='for_bar']") do
            @session.within("//li[contains(.,'Bar')]") do
              @session.click_link('Go')
            end
          end
          @session.body.should include('Another World')
        end

        it "should respect the outer scope" do
          @session.within("//div[@id='another_foo']") do
            @session.within("//li[contains(.,'With Simple HTML')]") do
              @session.click_link('Go')
            end
          end
          @session.body.should include('Hello world')
        end
      end

      it "should raise an error if the scope is not found on the page" do
        running {
          @session.within("//div[@id='doesnotexist']") do
          end
        }.should raise_error(Capybara::ElementNotFound)
      end
    end

    context "with forms" do
      it "should fill in a field and click a button" do
        @session.within("//li[contains(.,'Bar')]") do
          @session.click_button('Go')
        end
        extract_results(@session)['first_name'].should == 'Peter'
        @session.visit('/with_scope')
        @session.within("//li[contains(.,'Bar')]") do
          @session.fill_in('First Name', :with => 'Dagobert')
          @session.click_button('Go')
        end
        extract_results(@session)['first_name'].should == 'Dagobert'
      end
    end
  end

  describe '#within_fieldset' do
    before do
      @session.visit('/fieldsets')
    end

    it "should restrict scope to a fieldset given by id" do
      @session.within_fieldset("villain_fieldset") do
        @session.fill_in("Name", :with => 'Goldfinger')
        @session.click_button("Create")
      end
      extract_results(@session)['villain_name'].should == 'Goldfinger'
    end

    it "should restrict scope to a fieldset given by legend" do
      @session.within_fieldset("Villain") do
        @session.fill_in("Name", :with => 'Goldfinger')
        @session.click_button("Create")
      end
      extract_results(@session)['villain_name'].should == 'Goldfinger'
    end
  end

  describe '#within_table' do
    before do
      @session.visit('/tables')
    end

    it "should restrict scope to a fieldset given by id" do
      @session.within_table("girl_table") do
        @session.fill_in("Name", :with => 'Christmas')
        @session.click_button("Create")
      end
      extract_results(@session)['girl_name'].should == 'Christmas'
    end

    it "should restrict scope to a fieldset given by legend" do
      @session.within_table("Villain") do
        @session.fill_in("Name", :with => 'Quantum')
        @session.click_button("Create")
      end
      extract_results(@session)['villain_name'].should == 'Quantum'
    end
  end

end

shared_examples_for "session without javascript support" do
  describe "#evaluate_script" do
    before{ @session.visit('/with_js') }
    it "should raise an error" do
      running {
        @session.evaluate_script("1+5")
      }.should raise_error(Capybara::NotSupportedByDriverError)
    end
  end
end

shared_examples_for "session with javascript support" do
  describe "#evaluate_script" do
    before{ @session.visit('/with_js') }
    it "should return the evaluated script" do
      @session.evaluate_script("1+3").should == 4
    end
  end

  describe '#wait_for' do
    it "should wait for asynchronous load" do
      @session.visit('/with_js')
      @session.click_link('Click me')
      @session.wait_for("//a[contains(.,'Has been clicked')]")[:href].should == '#'
    end
  end

  describe '#click' do
    it "should wait for asynchronous load" do
      @session.visit('/with_js')
      @session.click_link('Click me')
      @session.click('Has been clicked')
    end
  end

  describe '#click_link' do
    it "should wait for asynchronous load" do
      @session.visit('/with_js')
      @session.click_link('Click me')
      @session.click_link('Has been clicked')
    end
  end
  
  describe '#click_button' do
    it "should wait for asynchronous load" do
      @session.visit('/with_js')
      @session.click_link('Click me')
      @session.click_button('New Here')
    end
  end
  
  describe '#fill_in' do
    it "should wait for asynchronous load" do
      @session.visit('/with_js')
      @session.click_link('Click me')
      @session.fill_in('new_field', :with => 'Testing...')
    end
  end
  
end

describe Capybara::Session do
  context 'with non-existant driver' do
    it "should raise an error" do
      running {
        Capybara::Session.new(:quox, TestApp).driver
      }.should raise_error(Capybara::DriverNotFoundError)
    end
  end
end

