Factory.define :product do |p|
  # required attributes
  p.name { Sham.random }
  p.permalink { Sham.random }

  # useful defaults
  p.hide_from_front_page false
end
