#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), 'helper')

steps_for :wiki do
  Given 'no articles in the wiki' do
    Article.destroy_all
  end

  When 'an article titled "$title" is addded to the wiki' do |title|
    create_article :title => title
  end

  When 'I access the wiki index' do
    get '/wiki'
  end

  Then 'the page should show "$text"' do |text|
    response.should have_text(/#{text}/)
  end
end

Story 'accessing the wiki index', %{
  As a user
  I want to view the wiki index
  So that I can get an overview of what's available
}, :type => RailsStory, :steps_for => :wiki do

  Scenario 'the wiki has no articles' do
    Given 'no articles in the wiki'
    When 'I access the wiki index'
    Then 'the page should show "Recently updated"'
    And 'the page should show "Top tags"'
  end

  Scenario 'articles are added to the wiki' do
    Given 'no articles in the wiki'
    When 'an article titled "foo" is addded to the wiki'
    And 'an article titled "bar" is addded to the wiki'
    And 'an article titled "baz" is addded to the wiki'
    And 'I access the wiki index'
    Then 'the page should show "Recently updated"'
    And 'the page should show "foo"'
    And 'the page should show "bar"'
    And 'the page should show "baz"'
  end
end
