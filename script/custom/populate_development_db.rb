#!/usr/bin/env script/runner
# (must run from top level of application)

include FixtureReplacement # aliased as FR

def chunk_of_text
  (Array.new(rand(100) + 25)).collect { |a| FR::random_string(rand(16) + 1) }.join(' ')
end

if ENV['RAILS_ENV'] != 'development'
  puts "warning: RAILS_ENV is '#{ENV['RAILS_ENV']}'"
  puts "(expected 'development')"
end

puts "Really populate development database with sample data?"
answer = gets.chomp
exit unless answer =~ /\Ay(es?)?\z/i

user = create_user(:passphrase => 'password', :passphrase_confirmation => 'password', :superuser => true)
user.emails.create!(:address => 'win@wincent.com')
puts "Created superuser with email address: win@wincent.com, password: password"

tags = ['foo', 'bar', 'baz', 'thing', 'this', 'that', 'the', 'other', 'xyz', 'abc.foo']

create_forum
create_forum(:description => 'talk about something')
create_forum(:description => 'talk about something else')
create_forum

create_post(:excerpt => chunk_of_text)
create_post(:accepts_comments => true, :excerpt => chunk_of_text)
50.times do
  post = create_post(:excerpt => chunk_of_text)
  post.tag tags.rand
end

10.times { create_product }

100.times { create_article(:body => chunk_of_text) }
