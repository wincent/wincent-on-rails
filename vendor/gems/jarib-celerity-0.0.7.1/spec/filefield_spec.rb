# encoding: utf-8
require File.dirname(__FILE__) + '/watirspec/spec_helper'

describe "FileField" do

  before :each do
    browser.goto(WatirSpec.files + "/forms_with_input_elements.html")
  end

  describe "#set" do
    it "sends content as correct content type for common file types" do
      browser.file_field(:name, "new_user_portrait").set("foo.doc")
      obj = browser.file_field(:name, "new_user_portrait").locate
      obj.getContentType.should == "application/msword"
    end
  end

end
