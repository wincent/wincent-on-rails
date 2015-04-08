require 'spec_helper'

describe Wincent::Application do
  it 'filters out the "passphrase" parameter' do
    expect(Rails.application.config.filter_parameters.include?(:passphrase)).to eq(true)
  end
end
