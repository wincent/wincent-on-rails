Sham.email_address do |n|
  "#{Sham.random_first_name.downcase}#{rand(1000)}@example.com"
end

Factory.define :email do |e|
  e.address { Sham.email_address }
  e.association :user
  e.verified true
end
