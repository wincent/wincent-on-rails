shared_examples_for 'ActiveRecord::Acts::Classifiable "moderate_as_ham!" method' do
  it 'should turn off the "awaiting moderation" flag' do
    lambda { @object.moderate_as_ham! }.should change(@object, :awaiting_moderation).from(true).to(false)
  end

  it 'should change the "awaiting moderation" flag in the database' do
    @object.moderate_as_ham!
    @object.class.find(@object.id).awaiting_moderation.should == @object.awaiting_moderation
  end

  it 'should not alter the comment "updated at" timestamp' do
    lambda { @object.moderate_as_ham! }.should_not change(@object, :updated_at)
  end

  it 'should not change the "updated at" timestamp in the database' do
    # as seems to be usual with ActiveRecord round-tripping, we lose precision and so must do a "to_s"
    @object.moderate_as_ham!
    @object.class.find(@object.id).updated_at.to_s.should == @object.updated_at.to_s
  end

  it 'should update the full-text search index if appropriate' do
    count = Needle.where(:model_class => @object.class.to_s,
                         :model_id    => @object.id).count
    count.should == 0
    @object.should_receive(:update_needles) if @object.class.private_method_defined?(:update_needles)
    @object.moderate_as_ham!
  end
end
