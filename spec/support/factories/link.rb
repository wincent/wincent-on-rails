Factory.define :link do |l|
  l.uri { "http://#{Sham.random}/#{Sham.random}" }
  l.permalink { Sham.random }
end
