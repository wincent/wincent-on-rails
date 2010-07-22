shared_examples_for '#moderate_as_ham!' do
  it 'turns off the "awaiting moderation" flag' do
    lambda { model.moderate_as_ham! }.should change(model, :awaiting_moderation).from(true).to(false)
  end

  it 'changes the "awaiting moderation" flag in the database' do
    model.moderate_as_ham!
    model.class.find(model.id).awaiting_moderation.should == model.awaiting_moderation
  end

  it 'does not alter the comment "updated at" timestamp' do
    lambda { model.moderate_as_ham! }.should_not change(model, :updated_at)
  end

  it 'does not change the "updated at" timestamp in the database' do
    # as seems to be usual with ActiveRecord round-tripping, we lose precision and so must do a "to_s"
    model.moderate_as_ham!
    model.class.find(model.id).updated_at.to_s.should == model.updated_at.to_s
  end

  it 'updates the full-text search index if appropriate' do
    count = Needle.where(:model_class => model.class.to_s,
                         :model_id    => model.id).count
    count.should == 0
    mock(model).update_needles if model.class.private_method_defined?(:update_needles)
    model.moderate_as_ham!
  end
end
