Factory.define :reset do |r|
  r.association :email
  r.email_address :fix_up_in_after_build

  r.after_build do |reset|
    # this kludge is needed because:
    #   (1) this is not a real column in the database, but we need to set it up
    #       for validation purposes
    #   (2) if we set it up unconditionally then we'll break specs which use
    #       the factory like this:
    #         Reset.make :email_address => nil
    # the only downside of this kludge is that the "valid_attributes" method
    # will spuriously report ":email_address => :fix_up_in_after_build", but
    # this seems an acceptable trade-off for clean specs
    if reset.email_address == :fix_up_in_after_build
      reset.email_address = reset.email.address
    end
  end
end
