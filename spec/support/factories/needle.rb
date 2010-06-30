Factory.define :needle do |n|
  # needles don't use real ActiveRecord associations, so don't even bother
  # creating a real model object for the model fields here
  n.model_class { 'Article' }
  n.model_id { 5000 }
  n.attribute_name { 'body' }
  n.content { 'word' }
end
