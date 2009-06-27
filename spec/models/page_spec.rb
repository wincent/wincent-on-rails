require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Page do
  it 'should be valid (new records)' do
    new_page.should be_valid
  end

  it 'should be valid (saved records)' do
    create_page.should be_valid
  end
end

describe Page, 'validation' do
  it 'should require the title to be present' do
    new_page(:title => '').should fail_validation_for(:title)
  end

  it 'should require the permalink to be present' do
    new_page(:permalink => '').should fail_validation_for(:permalink)
  end

  it 'should allow only letters, numbers and hyphens in the permalink' do
    new_page(:permalink => '%__%').should fail_validation_for(:permalink)
  end
end

describe Page, 'accessible attributes' do
  it 'should allow mass-assignment of the title attribute' do
    create_page.should allow_mass_assignment_of(:title => 'foo')
  end

  it 'should allow mass-assignment of the permalink attribute' do
    create_page.should allow_mass_assignment_of(:permalink => 'bar')
  end

  it 'should allow mass-assignment of the body attribute' do
    create_page.should allow_mass_assignment_of(:body => "<p>baz</p>\n")
  end

  it 'should allow mass-assignment of the front attribute' do
    create_page(:front => false).should allow_mass_assignment_of(:front => true)
  end
end
