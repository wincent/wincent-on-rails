require 'spec_helper'

describe Wincent::Application do
  it 'filters out the "passphrase" parameter' do
    Rails.application.config.filter_parameters.include?(:passphrase).should be_true
  end
end
