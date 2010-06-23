Sham.product_name do |n|
  if Rails.env == 'development'
    Sham.random
  else
    "Product #{n}"
  end
end

Sham.product_permalink do |n|
  if Rails.env == 'development'
    Sham.random
  else
    "product-#{n}"
  end
end

Factory.define :product do |p|
  # required attributes
  p.name { Sham.product_name }
  p.permalink { Sham.product_permalink }

  # useful defaults
  p.hide_from_front_page false
end
