require File.expand_path('../factory_girl', File.dirname(__FILE__))

Factory.define :attachment do |a|
  a.mime_type 'image/png'
  a.original_filename { Sham.random + '.png' }
  a.filesize { rand(1_000_000) + 4096 }
  a.path 'ab/aaaabbbbccccddddeeeeffff01234567890123456789012345678901234567'
  a.digest 'abaaaabbbbccccddddeeeeffff01234567890123456789012345678901234567'
end
