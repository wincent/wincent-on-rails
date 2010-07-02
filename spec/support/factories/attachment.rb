Factory.define :attachment do |a|
  a.mime_type 'image/png'
  a.original_filename { Sham.random + '.png' }
  a.filesize { rand(1_000_000) + 4096 }
end
