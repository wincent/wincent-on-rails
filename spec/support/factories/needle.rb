require File.expand_path('../factory_girl', File.dirname(__FILE__))

FactoryGirl.define do
  factory :needle do
    # needles don't use real ActiveRecord associations, so don't even bother
    # creating a real model object for the model fields here
    model_class 'Article'
    model_id 5000
    attribute_name 'body'
    content 'word'
  end
end
