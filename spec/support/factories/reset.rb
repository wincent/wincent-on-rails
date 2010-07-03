Factory.define :reset do |r|
  r.association :email

  r.after_build do |reset|
    reset.email_address = reset.email ? reset.email.address : nil
  end

  r.after_create do |reset|
    reset.email_address = reset.email.address
  end
end
