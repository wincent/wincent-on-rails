shared_examples_for '#moderate_as_ham!' do
  it 'turns off the "awaiting moderation" flag' do
    expect { model.moderate_as_ham! }.to change(model, :awaiting_moderation).from(true).to(false)
  end

  it 'changes the "awaiting moderation" flag in the database' do
    model.moderate_as_ham!
    expect(model.class.find(model.id).awaiting_moderation).to eq(model.awaiting_moderation)
  end

  it 'does not alter the comment "updated at" timestamp' do
    # Rails BUG: new regression in 3.0.0.rc2
    # https://rails.lighthouseapp.com/projects/8994/tickets/5440
    expect { model.moderate_as_ham! }.not_to change(model, :updated_at)
  end

  it 'does not change the "updated at" timestamp in the database' do
    # as seems to be usual with ActiveRecord round-tripping, we lose precision and so must do a "to_s"
    model.moderate_as_ham!
    expect(model.class.find(model.id).updated_at.to_s).to eq(model.updated_at.to_s)
  end

  it 'updates the full-text search index if appropriate' do
    count = Needle.where(:model_class => model.class.to_s,
                         :model_id    => model.id).count
    expect(count).to eq(0)
    mock(model).update_needles if model.class.private_method_defined?(:update_needles)
    model.moderate_as_ham!
  end
end
