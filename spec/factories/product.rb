Factory.define :product do |p|
  p.sequence(:name) { |n| "Product #{n}" }
  p.sequence(:permalink) { |n| "product-#{n}" }
end
