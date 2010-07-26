require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe 'Factories' do
  [ Article,
    Attachment,
    Comment,
    Confirmation,
    Email,
    Forum,
    Issue,
    Link,
    Message,
    Monitorship,
    Needle,
    Page,
    Post,
    Product,
    Repo,
    Reset,
    Tag,
    Tagging,
    Topic,
    Tweet,
    User,
    Word ].each do |model_class|

    describe "#{model_class}.make!" do
      it 'should produce a valid instance' do
        model_class.make!.should be_valid
      end
    end

    describe "#{model_class}.make" do
      it 'should produce a valid instance' do
        model_class.make.should be_valid
      end
    end
  end
end
