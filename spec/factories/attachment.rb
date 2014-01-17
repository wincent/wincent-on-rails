require_relative '../support/sham.rb'

FactoryGirl.define do
  factory :attachment do
    mime_type 'image/png'
    original_filename { Sham.random + '.png' }
    filesize { rand(1_000_000) + 4096 }
    path 'ab/aaaabbbbccccddddeeeeffff01234567890123456789012345678901234567'
    digest 'abaaaabbbbccccddddeeeeffff01234567890123456789012345678901234567'
  end
end
