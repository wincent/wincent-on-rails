Sham.email_address do |n|
  if Rails.env == 'development'
    "#{Sham.random_first_name.downcase}#{rand(1000)}@example.com"
  else
    "user#{n}@example.com"
  end
end

Factory.define :email do |e|
  e.address { Sham.email_address }
  e.association :user
  e.verified true
end
