require File.dirname(__FILE__) + '/../../spec_helper'

describe '/issues/_search' do
  include IssuesHelper

  before do
    @product1 = create_product
    @product2 = create_product
    Product.stub!(:find_all).and_return([@product1, @product2])
    assigns[:issue] = new_issue
  end

  def do_render
    render '/issues/_search'
  end

  it 'should display the search form' do
    do_render
    response.should have_tag('form[action=?][method=post]', search_issues_path) do
      # "product" pop-up
      with_tag('select#issue_product_id[name=?]', 'issue[product_id]') do
        # empty selection
        with_tag 'option[value=?]', ''
        with_tag 'option', ''

        # products
        with_tag 'option[value=?]', "#{@product1.id}"
        with_tag 'option', @product1.name
        with_tag 'option[value=?]', "#{@product2.id}"
        with_tag 'option', @product2.name
      end

      # "kind" pop-up
      with_tag('select#issue_kind[name=?]', 'issue[kind]') do
        # empty selection
        with_tag 'option[value=?]', ''
        with_tag 'option', ''

        # kinds
        Issue::KIND_MAP.keys.each do |key|
          with_tag 'option[value=?]', "#{key}"
          with_tag 'option', Issue::KIND_MAP[key].to_s.gsub('_', ' ')
        end
      end

      # "status" pop-up
      with_tag('select#issue_status[name=?]', 'issue[status]') do
        # empty selection
        with_tag 'option[value=?]', ''
        with_tag 'option', ''

        # statuses
        Issue::STATUS_MAP.keys.each do |key|
          with_tag 'option[value=?]', "#{key}"
          with_tag 'option', Issue::STATUS_MAP[key].to_s.gsub('_', ' ')
        end
      end

      # "search for" text field
      with_tag('input#issue_summary[name=?]', 'issue[summary]')
      with_tag('input#issue_summary[type=?]', 'text')

      # submit button
      with_tag('input#issue_submit[name=?]', 'commit')
      with_tag('input#issue_submit[type=?]', 'submit')
      with_tag('input#issue_submit[value=?]', 'Search')
    end
  end
end
