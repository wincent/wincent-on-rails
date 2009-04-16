# Security: create an empty whitelist of accessible attributes for all models in
# the app. See: http://guides.rubyonrails.org/security.html#mass-assignment
ActiveRecord::Base.send(:attr_accessible, nil)
