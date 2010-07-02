Factory.define :reset do |r|
  r.association :email

  r.after_build do |reset|
    # not a real column in the database, just for verification purposes
    # unfortunately it looks like a BUG: because this breaks specs which would:
    #   Reset.make :email_address => nil
    reset.email_address = reset.email.address
  end
end
