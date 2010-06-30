Factory.define :monitorship do |m|
  m.association :monitorable, :factory => :issue
  m.association :user
end
