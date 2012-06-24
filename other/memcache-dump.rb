#!/usr/bin/env ruby
#
# Dump all expiries and keys held by a local memcached instance for debugging
# purposes.
#
# Stolen from:
#   https://raw.github.com/gist/1479007/a93005345220289b965d107932639b54fba2dc50/gistfile1.rb
#
require 'net/telnet'

cache_dump_limit = 100
localhost = Net::Telnet::new("Host" => "localhost", "Port" => 11211, "Timeout" => 3)
slab_ids = []
localhost.cmd("String" => "stats items", "Match" => /^END/) do |c|
  matches = c.scan(/STAT items:(\d+):/)
  slab_ids = matches.flatten.uniq
end

puts
puts "Expires At\t\t\t\tCache Key"
puts '-'* 80
slab_ids.each do |slab_id|
  localhost.cmd("String" => "stats cachedump #{slab_id} #{cache_dump_limit}", "Match" => /^END/) do |c|
    matches = c.scan(/^ITEM (.+?) \[(\d+) b; (\d+) s\]$/).each do |key_data|
     (cache_key, bytes, expires_time) = key_data
     humanized_expires_time = Time.at(expires_time.to_i).to_s
    puts "[#{humanized_expires_time}]\t#{cache_key}"
    end
  end
end
puts

localhost.close
