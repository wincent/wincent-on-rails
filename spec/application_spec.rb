require File.expand_path('spec_helper', File.dirname(__FILE__))

describe Wincent::Application do
  it 'filters out the "passphrase" parameter' do
    Rails.application.config.filter_parameters.include?(:passphrase).should be_true
  end
end
