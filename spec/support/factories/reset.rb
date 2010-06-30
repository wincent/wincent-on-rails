Factory.define :reset do |r|
  r.association :email

  r.after_build do |reset|
    # BUG: unnecessarily denormalized here
    # (we store user needlessly, seeing as we store email already)
    reset.user = reset.email.user

    # not a real column in the database, just for verification purposes
    reset.email_address = reset.email.address
  end
end
